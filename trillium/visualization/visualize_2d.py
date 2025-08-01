import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import argparse
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt


def read_llc_field(file_path, nx, level=1, endian='>'):
    """
    Read a binary LLC 2D field (nx x 13*nx) from a multi-level .data file of 32-bit floats.
    Parameters
    ----------
    file_path : str
        Path to LLC .data file (all vertical levels concatenated).
    nx : int
        Tile dimension.
    level : int, optional
        Vertical level to read (1-based).
    endian : str, default '>'
        Byte order: '<' for little-endian, '>' for big-endian.
    Returns
    -------
    fld : ndarray, shape (nx, 13*nx)
        2D slice at the specified level.
    """
    count = nx * nx * 13
    dtype = np.dtype(endian + 'f4')
    byte_count = count * dtype.itemsize
    with open(file_path, 'rb') as f:
        f.seek((level - 1) * byte_count, os.SEEK_SET)
        raw = f.read(byte_count)
    data = np.frombuffer(raw, dtype=dtype)
    if data.size != count:
        raise ValueError(f"Expected {count} floats but got {data.size} at level {level}")
    fld = data.reshape((nx, 13*nx), order='F')
    return fld


def build_mosaic(fld, nx, vmin=None, vmax=None, cmap_name='Blues'):
    """
    Create an RGB numpy array (4*nx x 4*nx x 3) showing the five-tile LLC layout.
    Returns the image array and (vmin, vmax).
    """
    mask = (fld == 0) | np.isnan(fld)
    if vmin is None or vmax is None:
        valid = fld[~mask]
        vmin, vmax = valid.min(), valid.max()
    cmap = plt.colormaps[cmap_name]
    lut = (cmap(np.linspace(0, 1, 256))[:, :3] * 255).astype(np.uint8)
    lut[0] = np.array([0, 0, 0], dtype=np.uint8)
    norm = mcolors.Normalize(vmin=vmin, vmax=vmax)
    idx = (norm(fld) * 254 + 1).astype(np.uint8)
    idx[mask] = 0

    H = W = 4 * nx
    mosaic = np.zeros((H, W, 3), dtype=np.uint8)  # background masked as black
    # Face1
    mosaic[0:3*nx,   0:nx] = lut[idx[:, 0:3*nx].T]
    # Face2
    mosaic[0:3*nx,   nx:2*nx] = lut[idx[:, 3*nx:6*nx].T]
    # Face3
    img3 = np.rot90(idx[:, 6*nx:7*nx].T, k=-1)
    mosaic[3*nx:4*nx, 0:nx] = lut[img3]
    # Face4
    blk4 = idx[:, 7*nx:10*nx].reshape((3*nx, nx), order='F')[::-1, :]
    mosaic[0:3*nx,   2*nx:3*nx] = lut[blk4]
    # Face5
    blk5 = idx[:, 10*nx:13*nx].reshape((3*nx, nx), order='F')[::-1, :]
    mosaic[0:3*nx,   3*nx:4*nx] = lut[blk5]

    return mosaic[::-1, :, :], (vmin, vmax)


def overlay_colorbar(im, nx, scale, cmap_name='Blues'):
    draw = ImageDraw.Draw(im)
    draw.rectangle([(2*nx, 0), (4*nx-1, nx-1)], fill=(255, 255, 255))
    vmin, vmax = scale
    W, H = im.size
    cbar_h = int(0.03 * H)
    cbar_w = nx
    x0 = int(0.70 * W)
    y0 = (nx - cbar_h) // 2
    cmap = plt.colormaps[cmap_name]
    grad = (cmap(np.linspace(0, 1, cbar_w))[:, :3] * 255).astype(np.uint8)
    for i in range(cbar_w):
        for j in range(cbar_h):
            im.putpixel((x0 + i, y0 + j), tuple(grad[i]))
    font_size = max(int(W * 0.015), 12)
    try:
        from matplotlib import font_manager
        fp = font_manager.findfont('DejaVu Sans')
        font = ImageFont.truetype(fp, font_size)
    except:
        font = ImageFont.load_default()
    ticks = [0, cbar_w//2, cbar_w-1]
    labels = [f"{vmin:.2f}", f"{(vmin+vmax)/2:.2f}", f"{vmax:.2f}"]
    for pos, label in zip(ticks, labels):
        x = x0 + pos
        draw.line([(x, y0), (x, y0 + cbar_h)], fill=(0, 0, 0))
        bbox = draw.textbbox((0, 0), label, font=font)
        tw = bbox[2] - bbox[0]
        ty = y0 + cbar_h + max(int(font_size * 0.2), 2)
        draw.text((x - tw//2, ty), label, font=font, fill=(0, 0, 0))
    return im


def main():
    parser = argparse.ArgumentParser(description='Visualize a single LLC 2D slice from a 3D field')
    parser.add_argument('file', help='Path to LLC .data file (all levels)')
    parser.add_argument('--nx', type=int, required=True, help='Tile dimension')
    parser.add_argument('--level', type=int, default=1, help='Vertical level to display (1-based)')
    parser.add_argument('--vmin', type=float, default=None, help='Min color scale')
    parser.add_argument('--vmax', type=float, default=None, help='Max color scale')
    parser.add_argument('--cmap', default='Blues', help='Colormap name')
    parser.add_argument('--endian', choices=['<','>'], default='>', help='Byte order')
    parser.add_argument('--output','-o', help='Output PNG path')
    args = parser.parse_args()

    fld = read_llc_field(args.file, args.nx, level=args.level, endian=args.endian)
    mosaic, scale = build_mosaic(fld, args.nx, vmin=args.vmin, vmax=args.vmax, cmap_name=args.cmap)
    im = Image.fromarray(mosaic)
    im = overlay_colorbar(im, args.nx, scale, cmap_name=args.cmap)
    outname = args.output or os.path.splitext(os.path.basename(args.file))[0] + f'_lvl{args.level}.png'
    im.save(outname)
    print(f"Saved visualization to {outname} ({im.size[0]}x{im.size[1]} px)")


if __name__=='__main__':
    main()