import pygame
from pygame.locals import (
	K_TAB,
	K_ESCAPE,
	K_q,
	KEYDOWN,
	QUIT
)

SCREEN_WIDTH = 500
SCREEN_HEIGHT = 500

pygame.init()

screen = pygame.display.set_mode([SCREEN_WIDTH, SCREEN_HEIGHT])

running = True

while running:
	for event in pygame.event.get():
		if event.type == KEYDOWN:
			if event.key in [K_ESCAPE, K_q]:
				running = False
		elif event.type == QUIT:
			running = False
	
	screen.fill([255,255,255])

	pygame.draw.circle(screen, (0, 0, 255), (250, 250), 75)

	pygame.display.flip()

pygame.quit()
