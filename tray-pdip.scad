
/*
 * Mini JEDEC-style tray generator for packages conforming to JEDEC MS-001-D
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

/* [Parameters] */

// Text to emboss into the tray's tab
Tab_Text = "PDIP";

// Maximum length (in inches) of package body. Labeled D in MS-001-D.
Body_Length = 1.425; // 0.001

// Maxmimum height (in inches) of package body. Labeled A2 in MS-001-D.
Body_Height = 0.195; // 0.001

// Maximum spacing between bottom of unformed leads (in inches). Labeled eB in JEDEC MS-001-D.
Pin_Spacing_Unformed = 0.430; // 0.001

// Minimum spacing between botton of formed leads (in inches). Labeled eA in JEDEC MS-001-D.
Pin_Spacing_Formed = 0.300; // 0.001

// Maximum distance (in inches) from top of the body to the seating plane. Labeled A in JEDEC MS-001-D.
Body_Top_To_Seating_Plane_Height = 0.210; // 0.001

// Pin length from seating plane (in inches). Labeled L in JEDEC MS-001-D.
Pin_Length_From_Seating_Plane = 0.150; // 0.001

use <tray.scad>

/* [Hidden] */
$fs = 0.01;

Inch_To_mm = 25.4;

Well_Padding = [0.5, 0.5]; // mm

Body_Length_mm = Body_Length * Inch_To_mm;
Body_Height_mm = Body_Height * Inch_To_mm;
Pin_Spacing_Unformed_mm = Pin_Spacing_Unformed * Inch_To_mm;
Pin_Spacing_Formed_mm = Pin_Spacing_Formed * Inch_To_mm;
Body_Top_To_Seating_Plane_Height_mm = Body_Top_To_Seating_Plane_Height * Inch_To_mm;
Pin_Length_From_Seating_Plane_mm = Pin_Length_From_Seating_Plane * Inch_To_mm;

Well_Size_mm = [
    Well_Padding.x + Body_Length_mm + Well_Padding.x,
    Well_Padding.y + Pin_Spacing_Unformed_mm + Well_Padding.y,
    Body_Top_To_Seating_Plane_Height_mm + Pin_Length_From_Seating_Plane_mm
];

Tray(
    well_content_size = Well_Size_mm,
    tab_text = Tab_Text,
    well_hole = false,
    well_package_padding = [0, 0]
) PLCC_Well();

module PLCC_Well() {
    linear_extrude(height = Pin_Length_From_Seating_Plane_mm + (Body_Top_To_Seating_Plane_Height_mm - Body_Height_mm)) 
    polygon(
        points = [
            [
                0,
                0
            ],
            [
                Well_Size_mm.x,
                0
            ],
            [
                Well_Size_mm.x,
                Well_Size_mm.y
            ],
            [
                0,
                Well_Size_mm.y
            ],

            [
                Well_Padding.x,
                Well_Padding.y
            ],
            [
                Well_Padding.x + Body_Length_mm,
                Well_Padding.y
            ],
            [
                Well_Padding.x + Body_Length_mm,
                Well_Padding.y + (Pin_Spacing_Unformed_mm - Pin_Spacing_Formed_mm)/2
            ],
            [
                Well_Padding.x,
                Well_Padding.y + (Pin_Spacing_Unformed_mm - Pin_Spacing_Formed_mm)/2
            ],

            [
                Well_Size_mm.x - Well_Padding.x,
                Well_Size_mm.y - Well_Padding.y,
            ],
            [
                Well_Size_mm.x - (Well_Padding.x + Body_Length_mm),
                Well_Size_mm.y - Well_Padding.y,
            ],
            [
                Well_Size_mm.x - (Well_Padding.x + Body_Length_mm),
                Well_Size_mm.y - (Well_Padding.y + (Pin_Spacing_Unformed_mm - Pin_Spacing_Formed_mm)/2),
            ],
            [
                Well_Size_mm.x - Well_Padding.x,
                Well_Size_mm.y - (Well_Padding.y + (Pin_Spacing_Unformed_mm - Pin_Spacing_Formed_mm)/2),
            ]
        ],
        paths = [
            [0, 1, 2, 3],
            [4, 5, 6, 7],
            [8, 9, 10, 11]
        ]
    );
}
