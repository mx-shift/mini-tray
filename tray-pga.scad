
/*
 * Mini JEDEC-style tray for packages conforming to JEDEC MO-067-B
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
Tab_Text = "PGA";

// (X, Y, Z) size (in inches) of body. Labeled (D, E, A) in MO-067-B.
Body_Size = [1.78, 1.78, 0.145]; // [0:0.001:300]

// Number of pins per row/col. Labeled M in JEDEC MO-067-B.
Pin_Matrix_Size = 17; // 1.0

// Pin pitch (in inches).
Pin_Pitch = 0.100; // 0.001

// Maximum distance (in inches) from bottom of the body to the seating plane. Labeled Q in JEDEC MO-067-B.
Body_To_Seating_Plane_Height = 0.075; // 0.001

// Pin length from seating plane (in inches). Labeled L in JEDEC MO-067-B.
Pin_Length_From_Seating_Plane = 0.200; // 0.001

use <tray.scad>

/* [Hidden] */
$fs = 0.01;

Inch_To_mm = 25.4;

Pin_Pitch_mm = Pin_Pitch * Inch_To_mm;
Body_To_Seating_Plane_Height_mm = Body_To_Seating_Plane_Height * Inch_To_mm;
Pin_Length_From_Seating_Plane_mm = Pin_Length_From_Seating_Plane * Inch_To_mm;

Package_Size_mm = [
    Body_Size.x * Inch_To_mm,
    Body_Size.y * Inch_To_mm,
    Body_Size.z * Inch_To_mm + Body_To_Seating_Plane_Height_mm + Pin_Length_From_Seating_Plane_mm
];

Tray(
    well_content_size = Package_Size_mm,
    tab_text = Tab_Text
) PGA_Well();

module PGA_Well() {
    Package_To_Outermode_Pin_Center = [
        (Package_Size_mm.x - ((Pin_Matrix_Size - 1) * (Pin_Pitch_mm)))/2,
        (Package_Size_mm.y - ((Pin_Matrix_Size - 1) * (Pin_Pitch_mm)))/2,
    ];

    linear_extrude(height = Pin_Length_From_Seating_Plane_mm)
    polygon(
        points = [
            [
                Package_To_Outermode_Pin_Center.x + Pin_Pitch_mm / 4,
                Package_To_Outermode_Pin_Center.y + Pin_Pitch_mm / 4,
            ],
            [
                Package_Size_mm.x - Package_To_Outermode_Pin_Center.x - Pin_Pitch_mm / 4,
                Package_To_Outermode_Pin_Center.y + Pin_Pitch_mm / 4,
            ],
            [
                Package_Size_mm.x - Package_To_Outermode_Pin_Center.x - Pin_Pitch_mm / 4,
                Package_Size_mm.y - Package_To_Outermode_Pin_Center.y - Pin_Pitch_mm / 4,
            ],
            [
                Package_To_Outermode_Pin_Center.x + Pin_Pitch_mm / 4,
                Package_Size_mm.y - Package_To_Outermode_Pin_Center.y - Pin_Pitch_mm / 4,
            ],
            [
                Package_To_Outermode_Pin_Center.x + Pin_Pitch_mm * 3 / 4,
                Package_To_Outermode_Pin_Center.y + Pin_Pitch_mm * 3 / 4,
            ],
            [
                Package_Size_mm.x - Package_To_Outermode_Pin_Center.x - Pin_Pitch_mm * 3 / 4,
                Package_To_Outermode_Pin_Center.y + Pin_Pitch_mm * 3 / 4,
            ],
            [
                Package_Size_mm.x - Package_To_Outermode_Pin_Center.x - Pin_Pitch_mm * 3 / 4,
                Package_Size_mm.y - Package_To_Outermode_Pin_Center.y - Pin_Pitch_mm * 3 / 4,
            ],
            [
                Package_To_Outermode_Pin_Center.x + Pin_Pitch_mm * 3 / 4,
                Package_Size_mm.y - Package_To_Outermode_Pin_Center.y - Pin_Pitch_mm * 3 / 4,
            ],
        ],
        paths = [
            [0, 1, 2, 3],
            [4, 5, 6, 7]
        ]
    );
}
