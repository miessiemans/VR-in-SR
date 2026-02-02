import numpy as np
import pygame
import pygame_widgets
from pygame_widgets.slider import Slider
from pygame_widgets.textbox import TextBox

pygame.font.init()
my_font = pygame.font.SysFont('Objektiv Mk1', 20)
BLACK = (0, 0, 0)
origin = (300, 300)
c = 300
v = 150

# rest frame angles
angles_deg = np.arange(0, 360, 10)
angles_rad = np.deg2rad(angles_deg)
r = 300


def plot(angles_rad):
    for theta in angles_rad:
        x = r * np.cos(theta)
        y = r * np.sin(theta)
        pygame.draw.line(screen, BLACK, origin, ((origin[0] + x), (origin[1] - y)), width=1)
        
def aberrated(angles_rad, v):
    ar = []
    nc = v / c
    
    for x in range(0, len(angles_rad)):
        numer = np.cos(angles_rad[x]) + nc
        denom = 1 + nc*(np.cos(angles_rad[x]))
        t_prime = round(np.arccos((numer / denom)), 4)
        if t_prime in ar:
            ar.append(-t_prime)
        else:
            ar.append(t_prime)
    return ar


pygame.init()
screen = pygame.display.set_mode((600, 600))
slider = Slider(screen, 50, 50, 300, 10, min=0, max=300, step=1)
output = TextBox(screen, 360, 30, 50, 50, fontSize=30)

output.disable()



running = True
while running:
    events = pygame.event.get()
    screen.fill((255,255,255))

    pygame.draw.line(screen, BLACK, (0, 300), (600,300), width=2)
    v_ = slider.getValue()
    aberrated_angles = aberrated(angles_rad, v_)
    plot(aberrated_angles)
    
    output.setText(slider.getValue())
    

    pygame_widgets.update(events)
    pygame.display.flip()
    
    