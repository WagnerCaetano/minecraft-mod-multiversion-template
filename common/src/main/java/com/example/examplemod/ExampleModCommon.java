package com.example.examplemod;

/**
 * Loader-agnostic code shared between Forge 1.20.1 and NeoForge 1.21.1.
 * Keep Minecraft / loader APIs out of this module.
 */
public final class ExampleModCommon {
    public static final String MODID = "examplemod";

    private ExampleModCommon() {}

    public static String startupMessage() {
        return "Shared common module loaded";
    }
}
