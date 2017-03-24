--[[

   Awesome WM Tron Legacy Theme 1.5
   Distopico Vegan <distopico [at] riseup [dot] net>
   Licensed under GPL3

--]]

theme                                         = {}
theme.theme_path                              = os.getenv("HOME") .. "/.config/awesome/theme"
theme.wallpaper                               = os.getenv("HOME") .. "/Pictures/Wallpapers/Space/wallpaper8534.jpg"
theme.icon_theme                              = "Moka"

theme.font                                    = "Hack 8"

theme.bg_normal                               = "#001214"
theme.bg_focus                                = "#001214"
theme.bg_urgent                               = "#001214"
theme.bg_minimize                             = "#001214"

theme.fg_normal                               = "#aaaaaa"
theme.fg_focus                                = "#00FFFF"
theme.fg_urgent                               = "#e0c625"
theme.fg_minimize                             = "#15abc3"

-- | Systray | --
theme.bg_systray                              = theme.bg_normal
theme.systray_icon_spacing                    = 5

-- | Borders | --
theme.border_width                            = 1
theme.border_normal                           = "#000000"
theme.border_focus                            = "#005050"
theme.border_marked                           = "#91231c"

-- | Borders | --
theme.taglist_squares_sel                      = theme.theme_path .. "/taglist/square_sel.png"
theme.taglist_squares_unsel                    = theme.theme_path .. "/taglist/square_unsel.png"
theme.taglist_fg_focus                         = "#00FFFF"
theme.taglist_font                             = "Icons 10"

-- | Menu | --
theme.menu_icon                                = theme.theme_path .. "/icons/menu.png"
theme.menu_submenu_icon                        = theme.theme_path .. "/icons/submenu.png"
theme.menu_height                              = 15
theme.menu_width                               = 100

-- | Titkebar | --
theme.titlebar_close_button_focus               = theme.theme_path .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.theme_path .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active        = theme.theme_path .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.theme_path .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.theme_path .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.theme_path .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active       = theme.theme_path .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.theme_path .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.theme_path .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.theme_path .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active     = theme.theme_path .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.theme_path .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.theme_path .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.theme_path .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = theme.theme_path .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.theme_path .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.theme_path .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.theme_path .. "/titlebar/maximized_normal_inactive.png"

-- | Separators | --

theme.spr1px                                    = theme.theme_path .. "/separators/spr1px.png"
theme.spr2px                                    = theme.theme_path .. "/separators/spr2px.png"
theme.spr4px                                    = theme.theme_path .. "/separators/spr4px.png"
theme.spr5px                                    = theme.theme_path .. "/separators/spr5px.png"
theme.spr10px                                   = theme.theme_path .. "/separators/spr10px.png"

-- | Layout | --
theme.layout_fairh                              = theme.theme_path .. "/layouts/fairh.png"
theme.layout_fairv                              = theme.theme_path .. "/layouts/fairv.png"
theme.layout_floating                           = theme.theme_path .. "/layouts/floating.png"
theme.layout_magnifier                          = theme.theme_path .. "/layouts/magnifier.png"
theme.layout_max                                = theme.theme_path .. "/layouts/max.png"
theme.layout_fullscreen                         = theme.theme_path .. "/layouts/fullscreen.png"
theme.layout_tilebottom                         = theme.theme_path .. "/layouts/tilebottom.png"
theme.layout_tileleft                           = theme.theme_path .. "/layouts/tileleft.png"
theme.layout_tile                               = theme.theme_path .. "/layouts/tile.png"
theme.layout_tiletop                            = theme.theme_path .. "/layouts/tiletop.png"
theme.layout_spiral                             = theme.theme_path .. "/layouts/spiral.png"
theme.layout_dwindle                            = theme.theme_path .. "/layouts/dwindle.png"

-- | Misc | --
theme.awesome_icon                              = theme.theme_path .. "/icons/awesome.png"
theme.awesome_icon_w                            = theme.theme_path .. "/icons/awesome_w.png"

return theme
