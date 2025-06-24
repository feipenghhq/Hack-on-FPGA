# -------------------------------------------------------------------
# Copyright 2025 by Heqing Huang (feipenghhq@gamil.com)
# -------------------------------------------------------------------
#
# Project: VGA
# Author: Heqing Huang
# Date Created: 06/21/2025
#
# -------------------------------------------------------------------
# Display the screen from VGA signals
# -------------------------------------------------------------------


import pygame
import numpy as np
from threading import Thread
from cocotb.triggers import FallingEdge

VGA_WIDTH  = 640
VGA_HEIGHT = 480
H_BACK_PORCH = 48
V_BACK_PORCH = 33

class VGA:

    def __init__(self):
        self.framebuffer = np.zeros((VGA_WIDTH, VGA_HEIGHT, 3), dtype=np.uint16)
        self.quit = False

    def pygame_display(self):
        """
        Pygame display thread
        """
        pygame.init()
        screen = pygame.display.set_mode((VGA_WIDTH, VGA_HEIGHT))
        pygame.display.set_caption("VGA Output")
        clock = pygame.time.Clock()
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    self.quit = True
                    return True
            # Convert framebuffer to surface
            surface = pygame.surfarray.make_surface(self.framebuffer)
            screen.blit(surface, (0, 0))
            pygame.display.update()
            clock.tick(60)  # Refresh at 60Hz

    def start_display(self):
        Thread(target=self.pygame_display, daemon=True).start()

    def set_vga_signal(self, clk, hsync, vsync, r, g, b):
        """
        Set VGA signal from DUT
        """
        self.clk = clk
        self.HSYNC = hsync
        self.VSYNC = vsync
        self.R = r
        self.G = g
        self.B = b

    async def monitor_vga(self):
        """
        Monitor the VGA signal and create frame for pygame display

        VGA Timing:

                    |<--------- Active Video -------->|<-- Front Porch -->|<-- Sync Pulse -->|<-- Back Porch -->|
                    |---------------------------------|-------------------|------------------|------------------|
                     _____________________________________________________                    __________________
        H/VSYNC:                                                          |__________________|
        """
        hc = 0
        vc = 0
        hsync = 0
        hsync_d = 0
        vsync = 0
        vsync_d = 0
        while True:
            await FallingEdge(self.clk)
            hsync = self.HSYNC.value.integer
            vsync = self.VSYNC.value.integer
            red   = self.R.value.integer
            green = self.G.value.integer
            blue  = self.B.value.integer

            # Detect new line (hsync), starting from the Back Porch
            if hsync_d == 0 and hsync == 1:
                hc = 0
            else:
                hc += 1
            # Detect new frame (vsync)
            if vsync_d == 0 and vsync == 1 :
                vc = 0
            elif hsync_d == 0 and hsync == 1: # vsync only update when hsync complete one line
                vc += 1
            # Write pixel
            x = hc - H_BACK_PORCH
            y = vc - V_BACK_PORCH
            if 0 <= x < VGA_WIDTH and 0 <= y < VGA_HEIGHT:
                self.framebuffer[x, y] = [red, green, blue]
            # update delayed sync
            hsync_d = hsync
            vsync_d = vsync

