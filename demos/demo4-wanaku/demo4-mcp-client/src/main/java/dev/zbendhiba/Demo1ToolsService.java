package dev.zbendhiba;

import dev.langchain4j.agent.tool.Tool;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.Random;

@ApplicationScoped
public class Demo1ToolsService {

    private final Random random = new Random();

    @Tool("Get weather information for any city (simulated). Returns temperature, condition, and a fun weather fact.")
    public String weather(String city) {
        String[] conditions = {"sunny", "cloudy", "rainy", "snowy", "foggy", "stormy"};
        String[] temps = {"22°C", "15°C", "8°C", "25°C", "18°C", "12°C", "30°C", "5°C"};
        String[] funFacts = {
            "Did you know that lightning strikes the Earth about 100 times per second?",
            "The highest temperature ever recorded was 56.7°C in Death Valley!",
            "Snowflakes are actually ice crystals that form around tiny particles in the air.",
            "Rainbows appear when sunlight is refracted through water droplets in the air.",
            "The windiest place on Earth is Commonwealth Bay in Antarctica!"
        };

        String condition = conditions[random.nextInt(conditions.length)];
        String temp = temps[random.nextInt(temps.length)];
        String funFact = funFacts[random.nextInt(funFacts.length)];

        return String.format("🌤️ Weather in %s: %s, %s\n\n💡 Fun fact: %s", 
            city, condition, temp, funFact);
    }

    @Tool("Generate a random interesting fact about science, nature, or technology.")
    public String random_fact() {
        String[] facts = {
            "🧠 The human brain contains approximately 86 billion neurons!",
            "🌍 Earth is the only known planet with plate tectonics.",
            "🐙 Octopuses have three hearts and blue blood!",
            "🚀 A day on Venus is longer than its year (243 Earth days vs 225 Earth days).",
            "🦋 Butterflies taste with their feet!",
            "🌙 The Moon is moving away from Earth at about 3.8 cm per year.",
            "🐝 Honey never spoils - archaeologists have found edible honey in ancient Egyptian tombs!",
            "⚡ Lightning can heat the air to temperatures five times hotter than the surface of the Sun!",
            "🦒 A giraffe's tongue can be up to 20 inches long!",
            "🌊 The Pacific Ocean is larger than all land masses combined."
        };

        return facts[random.nextInt(facts.length)];
    }

    @Tool("Calculate simple math expressions. Supports basic arithmetic: +, -, *, /, and parentheses.")
    public String calculate(String expression) {
        try {
            // Simple expression evaluator for basic math
            expression = expression.replaceAll("\\s+", "");
            
            // Basic validation
            if (!expression.matches("[0-9+\\-*/().\\s]+")) {
                return "❌ Error: Only numbers and basic operators (+, -, *, /, parentheses) are allowed.";
            }

            // Use JavaScript engine for calculation (simple approach)
            javax.script.ScriptEngineManager manager = new javax.script.ScriptEngineManager();
            javax.script.ScriptEngine engine = manager.getEngineByName("JavaScript");
            
            if (engine == null) {
                return "❌ Error: Calculation engine not available.";
            }

            Object result = engine.eval(expression);
            return String.format("🧮 %s = %s", expression, result.toString());
            
        } catch (Exception e) {
            return "❌ Error: Invalid expression. Please use numbers and basic operators (+, -, *, /, parentheses).";
        }
    }

    @Tool("Generate a personalized greeting message for any name.")
    public String greet(String name) {
        String[] greetings = {
            "Hello", "Hi there", "Greetings", "Hey", "Welcome", "Good day", "Salutations"
        };
        
        String[] compliments = {
            "wonderful", "amazing", "fantastic", "brilliant", "awesome", "incredible", "marvelous"
        };

        String greeting = greetings[random.nextInt(greetings.length)];
        String compliment = compliments[random.nextInt(compliments.length)];

        return String.format("👋 %s, %s! It's great to meet you, %s person! 😊", 
            greeting, name, compliment);
    }
}
