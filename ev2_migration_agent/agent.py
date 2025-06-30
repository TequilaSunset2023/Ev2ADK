from typing import Optional, Dict, Any
from dotenv import load_dotenv

load_dotenv()

import datetime
import os
import subprocess
import json
from zoneinfo import ZoneInfo
from google.adk.tools.agent_tool import AgentTool
from google.adk.tools import ToolContext, FunctionTool
from google.adk.tools import FunctionTool
from google.adk.tools.tool_context import ToolContext
from google.adk.tools.base_tool import BaseTool
from google.adk.agents import LlmAgent, SequentialAgent, LoopAgent, BaseAgent
from google.adk.agents.callback_context import CallbackContext
from google.adk.models.lite_llm import LiteLlm, LlmResponse
from google.genai.types import Content, Part, FunctionCall, GenerateContentConfig
from google.adk.planners.built_in_planner import BuiltInPlanner
from pydantic import BaseModel, Field

from ev2_migration_agent.tools.ev2_tools import (
    get_bicep_templates,
    get_bicep_digest,
    get_ev2_migration_target_folder
    )

def digest_agent_after_tool_modifier(
    tool: BaseTool, args: Dict[str, Any], tool_context: ToolContext, tool_response: Dict
) -> Optional[Dict]:
    """Inspects/modifies the tool result after execution."""

    tool_name = tool.name
    state = tool_context.state
    if tool_name == 'get_bicep_digest':
        state["bicep_digest"] = tool_response
    return None

bicep_digest_extract_agent = LlmAgent(
    name="bicep_digest_extract_agent",
    model=LiteLlm(model="azure/gpt-4.1"),
    description=(
        "Use tool to get digest of user given bicep file."
    ),
    instruction=(
        """
        You are a helpful assistant who use .
        Your response must be pure kusto query text wrapped with json format, 
        it means a valid kusto query which can be executed directly in Azure Monitor.
        Your response MUST be a raw json which can be deserialized directly, Do not use markdown marks like ```json, 

        response format example:
        {
            "kusto_query_extracted": "let mitigationStep = ```Mitigation steps not added.```;InsightsMetrics| where Namespace =~ 'prometheus' and Name == 'DRU_health_check_gauge'| extend tags=parse_json(Tags)| extend ClusterName = tostring(tags.['ClusterName'])"
        }
        """
    ),
    tools=[
        FunctionTool(
            name="get_bicep_digest",
            description="Get the digest of a Bicep file given path, including parameters and resources, their names, types, API versions, and line number(s).",
            function=get_bicep_digest,
        )
    ],
    include_contents='none',
    after_tool_callback=digest_agent_after_tool_modifier,
)

root_agent = SequentialAgent(
    name="root_agent",
    description=(
        "Agent to migrate bicep to ev2."
    ),
    sub_agents=[
        kusto_query_extract_agent
    ],
)

# 把 corresponding_prom_metric_of_la_table_finding_loop_agent 里的 corresponding_prom_metric_of_la_table_finding_agent
# 拆成一个loop agent，里面3个agent，分别是，
# 1. 分析还有需要哪些prom metric 可能有帮助，
# 2. 找到对应的prom metric 值
# 3. 看有没有帮助，更新状态，并且决定是否继续