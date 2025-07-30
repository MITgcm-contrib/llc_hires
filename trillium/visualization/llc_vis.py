import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import argparse
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt


def read_llc(fnam, nx=270, level=1, prec='float32'):
    """
    Memory-map a big-endian LLC .data file and extract one vertical level.
    """
    try:
        dtype = np.dtype(prec).newbyteorder('>')
    except TypeError:
        raise ValueError(f"Unsupported precision '{prec}'")

    pts_per_level = nx * nx * 13
    arr = np.memmap(fnam, dtype=dtype, mode='r')
    start = (level - 1) * pts_per_level
    stop = start + pts_per_level
    if stop > arr.size:
        raise ValueError("Level exceeds file size")

    data = arr[start:stop].reshape((nx, 13*nx), order='F')
    return np.array(data)


def compute_speed(u, v):
    """
    Compute surface speed from 2D U and V at surface.
    """
    return np.sqrt(u**2 + v**2)


def build_mosaic(fld, nx, vmin=None, vmax=None, cmap_name='Blues'):
    """
    Build a 2D LLC mosaic array (4*nx x 4*nx x 3) from a 2D field.
    Returns mosaic array and (vmin, vmax) scale.
    """
    mask = (fld == 0) | np.isnan(fld)
    if vmin is None or vmax is None:
        ocean = fld[~mask]
        vmin, vmax = ocean.min(), ocean.max()
    cmap = plt.colormaps[cmap_name]
    lut = (cmap(np.linspace(0,1,256))[:,:3] * 255).astype(np.uint8)
    lut[0] = np.array([0, 0, 0], dtype=np.uint8)
    norm = mcolors.Normalize(vmin=vmin, vmax=vmax)
    idx = (norm(fld) * 254 + 1).astype(np.uint8)
    idx[mask] = 0
    H = W = 4 * nx
    mosaic = np.full((H, W, 3), 255, dtype=np.uint8)
    # Face 1
    mosaic[0:3*nx, 0:nx] = lut[idx[:, 0:3*nx].T]
    # Face 2
    mosaic[0:3*nx, nx:2*nx] = lut[idx[:, 3*nx:6*nx].T]
    # Face 3
    img3 = np.rot90(idx[:, 6*nx:7*nx].T, k=-1)
    mosaic[3*nx:4*nx, 0:nx] = lut[img3]
    # Face 4
    blk4 = idx[:, 7*nx:10*nx].reshape((3*nx, nx), order='F')[::-1, :]
    mosaic[0:3*nx, 2*nx:3*nx] = lut[blk4]
    # Face 5
    blk5 = idx[:, 10*nx:13*nx].reshape((3*nx, nx), order='F')[::-1, :]
    mosaic[0:3*nx, 3*nx:4*nx] = lut[blk5]
    return mosaic[::-1, :, :], (vmin, vmax)


def overlay_colorbar(im, nx, scale, cmap_name='Blues'):
    """
    Overlay a horizontal colorbar on PIL Image im (top-right),
    with ticks and labels sized relative to image dimensions.
    """
    draw = ImageDraw.Draw(im)
    # clear two top-right tiles to white
    draw.rectangle([(2*nx, 0), (4*nx-1, nx-1)], fill=(255,255,255))
    vmin, vmax = scale
    W, H = im.size
    # colorbar dimensions
    cbar_h = int(0.03 * H)
    cbar_w = nx
    x0 = int(0.70 * W)
    # center bar vertically in white tile region
    y0 = (nx - cbar_h) // 2
    # draw gradient
    cmap = plt.colormaps[cmap_name]
    grad = cmap(np.linspace(0,1,cbar_w))[:,:3]
    grad_rgb = (grad * 255).astype(np.uint8)
    for i in range(cbar_w):
        for j in range(cbar_h):
            im.putpixel((x0 + i, y0 + j), tuple(grad_rgb[i]))
    # determine font size ~1.5% of width
    font_size = max(int(W * 0.015), 12)
    try:
        from matplotlib import font_manager
        font_path = font_manager.findfont("DejaVu Sans")
        font = ImageFont.truetype(font_path, font_size)
    except Exception:
        font = ImageFont.load_default()
    # draw ticks and labels
    ticks = [0, cbar_w//2, cbar_w-1]
    labels = [f"{vmin:.2f}", f"{(vmin+vmax)/2:.2f}", f"{vmax:.2f}"]
    for pos, label in zip(ticks, labels):
        x = x0 + pos
        draw.line([(x, y0), (x, y0 + cbar_h)], fill=(0,0,0))
        bbox = draw.textbbox((0,0), label, font=font)
        tw = bbox[2] - bbox[0]
        ty = y0 + cbar_h + max(int(font_size*0.2), 2)
        draw.text((x - tw//2, ty), label, font=font, fill=(0,0,0))
    return im


def main():
    parser = argparse.ArgumentParser(
        description='Optimized LLC speed mosaic generator with adaptive colorbar')
    parser.add_argument('parent', help='Dir with U.*.data & V.*.data')
    parser.add_argument('--num', type=int, required=True,
                        help='Numeric identifier zero-padded to 10 digits')
    parser.add_argument('--nx', type=int, default=270, help='Tile dimension')
    parser.add_argument('--level', type=int, default=1, help='Vertical level')
    parser.add_argument('--vmin', type=float, default=None, help='Min value')
    parser.add_argument('--vmax', type=float, default=None, help='Max value')
    args = parser.parse_args()
    num_str = f"{args.num:010d}"
    u_file = os.path.join(args.parent, f"U.{num_str}.data")
    v_file = os.path.join(args.parent, f"V.{num_str}.data")
    u = read_llc(u_file, nx=args.nx, level=args.level)
    v = read_llc(v_file, nx=args.nx, level=args.level)
    speed = compute_speed(u, v)
    mosaic, scale = build_mosaic(speed, args.nx, vmin=args.vmin, vmax=args.vmax)
    im = Image.fromarray(mosaic)
    im = overlay_colorbar(im, args.nx, scale)
    out_file = f"{num_str}.png"
    H, W = im.size[1], im.size[0]
    im.save(out_file)
    print(f"Saved optimized LLC mosaic to {out_file} ({W}x{H} px)")

if __name__ == '__main__':
    main()

