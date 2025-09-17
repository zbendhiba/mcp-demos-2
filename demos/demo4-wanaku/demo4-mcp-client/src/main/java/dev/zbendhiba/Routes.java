package dev.zbendhiba;


import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.telegram.model.IncomingMessage;

@ApplicationScoped
public class Routes extends RouteBuilder {

    @Inject
    MyAiService myAIService;

    @Override
    public void configure() throws Exception {
        System.out.println("$$$$$$$$$$$$$");
        from("telegram:bots")
                .log("hello")
                .log("id is ${header.CamelTelegramChatId}")
                .process(exchange -> {
                    IncomingMessage incomingMessage = exchange.getIn().getBody(IncomingMessage.class);
                    String result = myAIService.chat(incomingMessage.getText());
                    exchange.getIn().setBody(result);
                })
                .log("end is ${body}")
                .to("telegram:bots")
        ;
    }
}
