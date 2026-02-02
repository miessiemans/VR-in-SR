import numpy as np
import pygame
from pygame_widgets.slider import Slider
import pygame_widgets

pygame.init()
win = pygame.display.set_mode((800, 800))
clock = pygame.time.Clock()

BLACK = (0, 0, 0)
GREEN = (0, 155, 0)
CENTER = np.array([400, 400])
R = 300
c = 300
f = 600


def aberrate_3d(dirs, v, c):
    beta = v / c
    gamma = 1.0 / np.sqrt(1 - beta**2)

    x, y, z = dirs.T

    denom = 1 + beta * x

    x_p = (x + beta) / denom
    y_p = y / (gamma * denom)
    z_p = z / (gamma * denom)

    return np.column_stack((x_p, y_p, z_p))


def evenly_spaced_directions(n_theta=30, n_phi=60):
    theta = np.linspace(0, np.pi, n_theta)        # polar angle
    phi = np.linspace(0, 2*np.pi, n_phi, endpoint=False)

    theta, phi = np.meshgrid(theta, phi, indexing='ij')

    x = np.cos(theta)
    y = np.sin(theta) * np.cos(phi)
    z = np.sin(theta) * np.sin(phi)

    return np.stack((x, y, z), axis=-1).reshape(-1, 3)



def project_points(points, f, center):
    x = points[:, 0]
    y = points[:, 1]
    z = points[:, 2]

    # convention to avoid points behind the observer 
    mask = x > 1e-3
    x, y, z = x[mask], y[mask], z[mask]
    
    
    X = center[0] + f * (y / x)  
    Y = center[1] - f * (z / x)  ## minus because pygame y-axis

    return np.column_stack((X, Y)), mask

def intensity_prime(dirs, v, c):
    beta = v / c
    gamma = 1 / np.sqrt(1 - beta**2)
    cos_theta = dirs[:, 0]   
    D = 1 / (gamma * (1 - beta * cos_theta))  
    I_prime = D**3
    
    return I_prime

def colour(I):
    Ip = I * 0.05
    cc = 200 * Ip
    if cc > 255:
        return (255, 255, 255)
    if cc < 0:
        return (0, 0, 0)
    return (cc, cc, cc)
    


# Rays
N = 40
dirs = evenly_spaced_directions(N)

slider = Slider(win, 150, 740, 500, 20, min=0, max=299.999, step=0.001)

run = True
while run:
    clock.tick(60)
    events = pygame.event.get()
    for event in events:
        if event.type == pygame.QUIT:
            run = False

    win.fill(BLACK)

    v = slider.getValue()
    aberrated = aberrate_3d(dirs, v, c)
    
    intensities = intensity_prime(aberrated, v, c)

    screen_pts, mask = project_points(aberrated, f, CENTER)
    for i in range(0, len(screen_pts)):
        II = float(intensities[i])
        clr = colour(II)
        pygame.draw.circle(win, clr, (int(screen_pts[i][0]), int(screen_pts[i][1])), 2)
    pygame_widgets.update(events)
    pygame.display.flip()

pygame.quit()
