package dev.zbendhiba;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import io.quarkiverse.langchain4j.RegisterAiService;
import io.quarkiverse.langchain4j.mcp.runtime.McpToolBox;
import jakarta.enterprise.context.ApplicationScoped;


@RegisterAiService
@SystemMessage("You are a professional poet")
@ApplicationScoped
public interface MyAiService {

    @SystemMessage("""
        You are a an agent responding to the user
        """)
    @McpToolBox
    String chat(@UserMessage String userMessage);

}

