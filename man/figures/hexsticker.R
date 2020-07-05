library(hexSticker)
library(magick)
library(magrittr)

# generate sticker --------------------------------------------------------

logo <-
  image_read("man/figures/appid.png") %>%
  image_crop("200x140+0")

sticker(logo,
        package = "appId",
        p_size = 30,
        p_y = 1.4,
        p_color = "#2ea8d9",
        s_x = 1.04,
        s_y = .7,
        s_width = 1,
        s_height = 1.8,
        h_size = 3,
        h_color = "#2ea8d9",
        h_fill = "#ffffff",
        filename="man/figures/hexsticker.png")

