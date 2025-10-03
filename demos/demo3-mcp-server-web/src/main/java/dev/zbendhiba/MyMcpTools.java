package dev.zbendhiba;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatterBuilder;
import java.util.Random;

import io.quarkiverse.mcp.server.Tool;

public class MyMcpTools {
    
    private final Random random = new Random();

    @Tool(description = "Give the current time")
    public String time() {
        ZonedDateTime now = ZonedDateTime.now();
        return now.toLocalTime().format(new DateTimeFormatterBuilder()
                .appendPattern("HH:mm:ss").toFormatter());
    }

    @Tool(description = "Get simulated weather information for any city, along with a fun fact about the weather.")
    public String weather(String city) {
        String[] conditions = {"sunny ☀️", "cloudy ☁️", "rainy 🌧️", "snowy ❄️", "stormy ⛈️"};
        String[] temps = {"22°C", "15°C", "8°C", "0°C", "28°C", "10°C"};
        String[] weatherFacts = {
            "Did you know that a 'haboob' is a type of intense dust storm?",
            "The highest temperature ever recorded on Earth was 56.7°C (134°F) in Death Valley, USA.",
            "A single thunderstorm can contain millions of gallons of water.",
            "Snowflakes are never identical, each one has a unique crystalline structure.",
            "Lightning can strike the same place twice, and often does!"
        };
        
        String condition = conditions[random.nextInt(conditions.length)];
        String temp = temps[random.nextInt(temps.length)];
        String fact = weatherFacts[random.nextInt(weatherFacts.length)];

        return String.format("The simulated weather in %s is %s with a temperature of %s. %s", 
            city, condition, temp, fact);
    }

    @Tool(description = "Generate a random interesting fact about science, history, or general knowledge.")
    public String random_fact() {
        String[] facts = {
            "The shortest war in history was between Britain and Zanzibar on August 27, 1896. Zanzibar surrendered after 38 minutes.",
            "A group of owls is called a parliament.",
            "Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still edible.",
            "The human brain weighs about 3 pounds but uses 20% of the body's oxygen and calories.",
            "There are more stars in the universe than grains of sand on all the beaches on Earth."
        };
        return facts[random.nextInt(facts.length)];
    }


    @Tool(description = "Greet a person by their name.")
    public String greet(String name) {
        return String.format("Hello %s! 🎉 Welcome to my MCP demo at Devoxx - hope you enjoy the show!", name);
    }
}
