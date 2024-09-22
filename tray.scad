/*
 * Mini JEDEC-style tray generator
 *
 * Module for generating custom JEDEC-style trays that are the same width as a
 * JEDEC tray but only 1/3rd the width. Trays include a protruding tab with an
 * embossed label and a matching anti-tab to allow them to be placed next to
 * each other. The trays also include an inset and magnets for stacking.
 *
 * Inspired by https://www.compuphase.com/electronics/minitray.htm.
 *
 * Copyright 2024, Rick Altherr
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

use <MCAD/boxes.scad>

// Overlap for boolean operations
Epsilon = 0.005;

Minimum_Floor_Thickness = 1.0;

// Generate a tray with well areas large enough to fit the provided
// well_content_size. The number of wells and the tray thickness will be
// automatically calculated.  The child module provided will be invoked for
// each well location to place additional features inside the well. If the well
// is larger than 16x16, a hole will placed in the middle by default.
//
// Most package styles are supported by features placed on the bottom of the
// well. With the default well_package_padding settings, the wells will be
// 0.5mm larger than the well_content_size in the X and Y dimensions so the
// well contents can be based on the package size alone yet still have some
// space between the package and the well side walls. See tray-pdip.scad for an
// example of how to adjust this when a package needs to fill the entire XY
// space for a support feature.
module Tray(
        well_content_size,                  // How much empty [X, Y, Z] space (in mm) to provide to the child module for drawing well features
        tab_text,                           // What to emboss into the tab

        tray_height = 0,                    // mm.  When zero, z will be calculated from package height

        tab_size = [91.0, 7, 3.0],          // [X, Y] mm
        tab_offset = [18, -3.9, -3.0],      // Offset of tab from left-top-front edge of tray (in mm).
        tab_corner_radius = 1.5,            // mm
        tab_border = [2.0, 1.0],            // Border width (in mm) [left/right, top/bottom].
        tab_margin = 0.1,                   // Empty space (in mm) around tab for matching recess in adjacent tray.
        tab_padding = 0.5,                  // Space between the border and the text.
        tab_emboss_depth = 0.6,             // How deep (in mm) to recess around the embossed text.
        tab_font = "Geert",                 // Font used for the text.
        tab_font_height = 4,                // Tab font height (in mm).
        tab_font_spacing = 1.25,

        stacking_depth = 1.5,               // How deep (in mm) the bottom of one tray protrudes into another below it.
        stacking_border = [3.0, 5.0],       // Border width (in mm) around outside of tray before stacking recess beings [left/right, top/bottom].
        stacking_margin = [0.1, 0.1, 0.1],  // How much larger (in mm) to make the inset than the matching protrusion.
        stacking_chamfer = 1,               // How much larger (in mm) the top of the inset is than the bottom of the inset.

        magnet_diameter = 2.1,              // mm
        magnet_inset = [4, 2.6],            // mm

        well_border = [1, 1],               // [X, Y] thickness (in mm) of the border between wells.
        well_package_padding = [0.5, 0.5],  // [X, Y] space (in mm) between the well contents and the well border on each side.

        well_hole = true,                   // If true, a hole is placed in the middle of the well's floor.
        well_hole_padding = [6, 6],         // [X, Y] space (in mm) between well border and well hole.
        well_hole_size_min = [10, 10]       // Minimum [X, Y] size (in mm) of hole in the middle of the well.
) {
        tray_minimum_height = well_content_size.z + Minimum_Floor_Thickness + stacking_depth + stacking_margin.z;

        tray_size = [
            135.9,
            106.5,
            tray_height > tray_minimum_height ? tray_height : tray_minimum_height
        ];

        tab_origin = [
            tab_offset.x,
            tray_size.y + tab_offset.y,
            tray_size.z + tab_offset.z
        ];

        platten_size = [
            tray_size.x - 2*stacking_border.x,
            tray_size.y - 2*stacking_border.y
        ];

        platten_origin = [
            stacking_border.x,
            stacking_border.y,
            tray_size.z - stacking_depth - stacking_margin.z
        ];

        well_size = [
            well_package_padding.x + well_content_size.x + well_package_padding.x,
            well_package_padding.y + well_content_size.y + well_package_padding.y,
            well_content_size.z
        ];

        well_hole_size = [
            well_size.x - 2*well_hole_padding.x,
            well_size.y - 2*well_hole_padding.y,
            platten_origin.z - well_size.z
        ];

        well_grid_columns = floor(platten_size.x / (well_border.x/2 + well_size.x + well_border.x/2));
        well_grid_rows = floor(platten_size.y / (well_border.y/2 + well_size.y + well_border.y/2));

        well_grid_origin = [
            platten_origin.x + (platten_size.x - well_grid_columns * (well_border.x/2 + well_size.x + well_border.x/2))/2 + well_border.x/2,
            platten_origin.y + (platten_size.y - well_grid_rows * (well_border.y/2 + well_size.y + well_border.y/2))/2 + well_border.x/2,
            platten_origin.z - well_content_size.z
        ];

        union() {
            difference() {
                TrayOutline(
                    tray_size = tray_size,

                    platten_origin = platten_origin,
                    platten_size = platten_size,

                    tab_origin = tab_origin,
                    tab_size = tab_size,
                    tab_offset = tab_offset,
                    tab_corner_radius = tab_corner_radius,
                    tab_margin = tab_margin,

                    stacking_depth = stacking_depth,
                    stacking_border = stacking_border,
                    stacking_margin = stacking_margin,

                    magnet_diameter = magnet_diameter,
                    magnet_inset = magnet_inset
                );
                Tray_TabRecess(
                    tray_size = tray_size,
                    tab_origin = tab_origin,
                    tab_size = tab_size,
                    tab_offset = tab_offset,
                    tab_border = tab_border,
                    tab_emboss_depth = tab_emboss_depth
                );
                Tray_PlattenInset(
                    tray_size = tray_size,
                    platten_origin = platten_origin,
                    platten_size = platten_size,
                    stacking_depth = stacking_depth,
                    stacking_border = stacking_border,
                    stacking_margin = stacking_margin,
                    stacking_chamfer = stacking_chamfer
                );
                Tray_PlattenWells(
                    well_content_size = well_content_size,
                    well_grid_origin = well_grid_origin,
                    well_grid_rows = well_grid_rows,
                    well_grid_columns = well_grid_columns,
                    well_size = well_size,
                    well_border = well_border,
                    well_hole = well_hole,
                    well_hole_size = well_hole_size,
                    well_hole_size_min = well_hole_size_min,
                    well_hole_padding = well_hole_padding
                );
            };
            Tray_TabText(
                tab_origin = tab_origin,
                tab_size = tab_size,
                tab_border = tab_border,
                tab_padding = tab_padding,
                tab_emboss_depth = tab_emboss_depth,
                tab_font = tab_font,
                tab_font_height = tab_font_height,
                tab_font_spacing = tab_font_spacing,
                tab_text = tab_text
            );
            for (row = [0:1:well_grid_rows-1]) {
                for (col = [0:1:well_grid_columns-1]) {
                    well_origin = Well_Origin(well_grid_origin, well_size, well_border, row, col);
                    well_content_origin = [
                        well_origin.x + well_package_padding.x,
                        well_origin.y + well_package_padding.y,
                        well_origin.z
                    ];

                    translate(well_content_origin)
                    children(0);
                }
            }
        }
}

module TrayOutline(
        tray_size,      // [x, y, z] mm

        platten_origin,
        platten_size,

        tab_origin,
        tab_size,
        tab_offset,
        tab_corner_radius,
        tab_margin,

        stacking_depth,
        stacking_border,
        stacking_margin,

        magnet_diameter,
        magnet_inset
) {
        union() {
            translate([0, 0, stacking_depth])
            linear_extrude(height = tray_size.z - stacking_depth) 
                difference() {
                    polygon(points = [
                        [0, 0],

                        // Top-left corner has a 45deg chamber
                        [0, tray_size.y - 3],
                        [3, tray_size.y],

                        [tray_size.x, tray_size.y],
                        [tray_size.x, 0]
                    ]);

                    // Holes for magnets
                    magnet_locations = [
                        [
                            magnet_inset.x,
                            magnet_inset.y
                        ],
                        [
                            magnet_inset.x,
                            tray_size.y - magnet_inset.y
                        ],
                        [
                            tray_size.x - magnet_inset.x,
                            magnet_inset.y
                        ],
                        [
                            tray_size.x - magnet_inset.x,
                            tray_size.y - magnet_inset.y
                        ]
                    ];
                    for(location = magnet_locations) {
                        translate([location.x, location.y])
                            circle(d=magnet_diameter);
                    }

                    // Counter-tab, where the tab of another mini-tray fits in
                    translate([tab_offset.x - tab_margin, tab_offset.y - 0.1])
                        square([tab_size.x + 2 * tab_margin, tab_size.y + 0.1]);

                }
            
            // Tab on top edge
            translate([tab_origin.x + tab_size.x/2, tab_origin.y + tab_size.y/2 - Epsilon, tab_origin.z + tab_size.z/2]) {
                color("blue")
                roundedBox([tab_size.x, tab_size.y + Epsilon, tab_size.z + Epsilon], tab_corner_radius, true);
            }

            // Stacking protrusion
            linear_extrude(height = platten_origin.z) 
            translate([
                platten_origin.x + stacking_margin.x,
                platten_origin.y + stacking_margin.y,
            ])
            square([
                platten_size.x - 2*stacking_margin.x,
                platten_size.y - 2*stacking_margin.y
            ]);
        }
}

module Tray_TabRecess(
        tray_size,

        tab_origin,
        tab_size,
        tab_offset,
        tab_border,
        tab_emboss_depth
) {
        translate([
            tab_origin.x + tab_border.x,
            tab_origin.y + tab_border.y,
            tab_origin.z + tab_size.z - tab_emboss_depth
        ]) {
            cube([
                tab_size.x - 2*tab_border.x,
                tab_size.y - 2*tab_border.y,
                tab_emboss_depth + 2*Epsilon
            ]);
        }
}

module Tray_PlattenInset(
        tray_size,
        platten_origin,
        platten_size,
        stacking_depth,
        stacking_border,
        stacking_margin,
        stacking_chamfer
) {
        // Chamfer cuts into the tray border.
        translate([
            platten_origin.x - stacking_chamfer,
            platten_origin.y - stacking_chamfer,
            platten_origin.z
        ])
        polyhedron(
            points = [
                // Bottom is exactly the size of the platten
                [
                    stacking_chamfer,
                    stacking_chamfer,
                    0
                ],  // 0
                [
                    stacking_chamfer + platten_size.x,
                    stacking_chamfer,
                    0
                ],
                [
                    stacking_chamfer + platten_size.x,
                    stacking_chamfer + platten_size.y,
                    0
                ],
                [
                    stacking_chamfer,
                    stacking_chamfer + platten_size.y,
                    0
                ],

                // Chamfer starts midway up
                [
                    stacking_chamfer,
                    stacking_chamfer,
                    (tray_size.z - platten_origin.z)/2
                ],  // 0
                [
                    stacking_chamfer + platten_size.x,
                    stacking_chamfer,
                    (tray_size.z - platten_origin.z)/2
                ],
                [
                    stacking_chamfer + platten_size.x,
                    stacking_chamfer + platten_size.y,
                    (tray_size.z - platten_origin.z)/2
                ],
                [
                    stacking_chamfer,
                    stacking_chamfer + platten_size.y,
                    (tray_size.z - platten_origin.z)/2
                ],

                // Top is larger by the width of the chamfer
                [
                    0,
                    0,
                    tray_size.z - platten_origin.z + Epsilon
                ],
                [
                    stacking_chamfer + platten_size.x + stacking_chamfer,
                    0,
                    tray_size.z - platten_origin.z + Epsilon
                ],
                [
                    stacking_chamfer + platten_size.x + stacking_chamfer,
                    stacking_chamfer + platten_size.y + stacking_chamfer,
                    tray_size.z - platten_origin.z + Epsilon
                ],
                [
                    0,
                    stacking_chamfer + platten_size.y + stacking_chamfer,
                    tray_size.z - platten_origin.z + Epsilon
                ],
            ],
            faces = [
                [0, 1, 2, 3], // bottom
                [11, 10, 9, 8], // top
                [4, 5, 1, 0], // front-lower
                [8, 9, 5, 4], // front-upper
                [5, 6, 2, 1], // right-lower
                [9, 10, 6, 5], // right-upper
                [6, 7, 3, 2], // back-lower
                [10, 11, 7, 6], // back-upper
                [7, 4, 0, 3], // left-lower
                [11, 8, 4, 7], // left-upper
            ]
        );
}

function Well_Origin(
        well_grid_origin,
        well_size,
        well_border,
        row,
        col
) = [
        well_grid_origin.x + col * (well_size.x + well_border.x),
        well_grid_origin.y + row * (well_size.y + well_border.y),
        well_grid_origin.z
];

module Tray_PlattenWells(
        well_content_size,

        well_grid_origin,
        well_grid_rows,
        well_grid_columns,

        well_size,
        well_border,

        well_hole,
        well_hole_size,
        well_hole_size_min,
        well_hole_padding,
) {
        for(row = [0:1:well_grid_rows-1]) {
            for (col = [0:1:well_grid_columns-1]) {
                well_origin = Well_Origin(well_grid_origin, well_size, well_border, row, col);

                translate(well_origin)
                linear_extrude(height = well_content_size.z + Epsilon) 
                square([well_size.x, well_size.y]);

                if(
                    well_hole &&
                    well_hole_size.x >= well_hole_size_min.x &&
                    well_hole_size.y >= well_hole_size_min.y
                ) {
                    well_hole_origin = [
                        well_origin.x + well_hole_padding.x,
                        well_origin.y + well_hole_padding.y,
                        -Epsilon
                    ];

                    translate(well_hole_origin)
                    linear_extrude(height = well_hole_size.z + 2*Epsilon)
                    square([well_hole_size.x, well_hole_size.y]);
                }
            }
        }
}

module Tray_TabText(
        tab_origin,
        tab_size,
        tab_border,
        tab_padding,
        tab_emboss_depth,
        tab_font,
        tab_font_height,
        tab_font_spacing,
        tab_text
) {
        translate([
            tab_origin.x + tab_border.x + tab_padding,
            tab_origin.y + tab_border.y + tab_padding,
            tab_origin.z + tab_size.z - tab_emboss_depth - Epsilon
        ])
            linear_extrude(tab_emboss_depth + Epsilon)
                text(tab_text, font=tab_font, size=tab_font_height, spacing=tab_font_spacing);
}
