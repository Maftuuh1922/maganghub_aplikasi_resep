from pathlib import Path
from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[1] / "assets" / "onboarding"
OUT.mkdir(parents=True, exist_ok=True)
S = 2
W, H = 720, 600


def canvas():
    return Image.new("RGBA", (W * S, H * S), (0, 0, 0, 0))


def draw_shapes(index):
    im = canvas()
    d = ImageDraw.Draw(im)
    def ellipse(box, fill, outline=None, width=1):
        d.ellipse(tuple(round(v * S) for v in box), fill=fill, outline=outline, width=width * S)
    def rect(box, fill, radius=0, outline=None, width=1):
        b = tuple(round(v * S) for v in box)
        if radius:
            d.rounded_rectangle(b, radius=radius * S, fill=fill, outline=outline, width=width * S)
        else:
            d.rectangle(b, fill=fill, outline=outline, width=width * S)
    def line(points, fill, width=8):
        d.line([(round(x * S), round(y * S)) for x, y in points], fill=fill, width=width * S, joint="curve")
    if index == 1:
        # Flat-color dinner plate, fork, herbs, tomatoes and pasta.
        ellipse((174, 66, 574, 466), "#172D40")
        ellipse((198, 90, 550, 442), "#F3EBDD")
        ellipse((232, 124, 516, 408), "#FFFFFF")
        ellipse((307, 205, 437, 335), "#F2C14E")
        ellipse((328, 224, 415, 311), "#F7D56A")
        for x, y in [(285, 188), (450, 232), (280, 337), (445, 351), (371, 158)]:
            ellipse((x-13, y-13, x+13, y+13), "#EF715B")
        for x, y, rot in [(280, 235, 0), (458, 299, 1), (315, 355, 0), (403, 170, 1)]:
            ellipse((x-17, y-8, x+17, y+8), "#65A77B")
            line([(x-12, y), (x+12, y)], "#2C7053", 3)
        rect((126, 205, 156, 373), "#C7D7D8", 12)
        for y in [180, 195, 210, 225]: line([(126, y), (156, y)], "#C7D7D8", 5)
        line([(585, 174), (585, 366)], "#C7D7D8", 8)
        line([(568, 174), (568, 229)], "#C7D7D8", 7)
        line([(602, 174), (602, 229)], "#C7D7D8", 7)
        ellipse((552, 214, 618, 250), "#C7D7D8")
        rect((568, 232, 602, 372), "#C7D7D8", 13)
    elif index == 2:
        # Recipe card and flat ingredient tiles.
        rect((170, 88, 551, 488), "#172D40", 34)
        rect((190, 68, 531, 468), "#F3EBDD", 30)
        rect((218, 99, 502, 278), "#B7F397", 23)
        ellipse((278, 121, 442, 260), "#F3EBDD")
        ellipse((296, 139, 424, 249), "#F2C14E")
        for x, y in [(330, 175), (373, 207), (393, 161)]: ellipse((x-11, y-11, x+11, y+11), "#EF715B")
        rect((223, 306, 450, 320), "#172D40", 7)
        rect((223, 338, 472, 350), "#8DA3B5", 6)
        rect((223, 370, 422, 382), "#8DA3B5", 6)
        rect((223, 402, 464, 414), "#8DA3B5", 6)
        ellipse((464, 323, 520, 379), "#B7F397")
        line([(481, 351), (493, 363), (511, 340)], "#07131F", 6)
        # Small ingredient dish at lower left.
        ellipse((92, 364, 222, 494), "#172D40")
        ellipse((105, 377, 209, 481), "#F3EBDD")
        ellipse((127, 399, 187, 459), "#EF715B")
        ellipse((143, 405, 174, 450), "#F2C14E")
    else:
        # Recipe book with a bright heart marker and saved dish.
        rect((118, 164, 458, 488), "#172D40", 31)
        rect((135, 143, 442, 468), "#F3EBDD", 27)
        rect((287, 143, 442, 468), "#DFE8D8", 20)
        line([(287, 164), (287, 445)], "#8DA3B5", 4)
        ellipse((180, 195, 256, 271), "#B7F397")
        ellipse((178, 194, 216, 232), "#EF715B")
        ellipse((216, 194, 254, 232), "#EF715B")
        d.polygon([(178*S, 214*S), (254*S, 214*S), (216*S, 255*S)], fill="#EF715B")
        rect((171, 298, 260, 308), "#172D40", 5)
        rect((171, 324, 264, 333), "#8DA3B5", 5)
        rect((171, 348, 250, 357), "#8DA3B5", 5)
        ellipse((338, 213, 492, 367), "#B7F397")
        # Build heart from two round lobes and a triangular point.
        ellipse((359, 237, 414, 291), "#EF715B")
        ellipse((399, 237, 454, 291), "#EF715B")
        d.polygon([(359*S, 267*S), (454*S, 267*S), (406*S, 324*S)], fill="#EF715B")
        for x, y in [(485, 177), (526, 278), (488, 397)]:
            # Four-point mint sparkles, flat fill only.
            d.polygon([(x*S, (y-18)*S), ((x+6)*S, (y-6)*S), ((x+18)*S, y*S), ((x+6)*S, (y+6)*S), (x*S, (y+18)*S), ((x-6)*S, (y+6)*S), ((x-18)*S, y*S), ((x-6)*S, (y-6)*S)], fill="#B7F397")
    return im.resize((W, H), Image.Resampling.LANCZOS)


for n in (1, 2, 3):
    path = OUT / f"onboarding_{n}.png"
    draw_shapes(n).save(path, optimize=True)
    print(f"generated {path} ({path.stat().st_size} bytes)")
