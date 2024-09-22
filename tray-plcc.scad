
/*
 * Mini JEDEC-style tray for packages conforming to JEDEC MS-018-A
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
Tab_Text = "PLCC";

// (X, Y, Z) size (in inches) of package including body and pins. Labeled (D, E, A) in MS-018-A.
Package_Size = [1.195, 1.195, 0.180]; // [0:0.001:300]

// Minimum (X, Y) distance (in inches) between centers of pins and center of package. Labeled (D2, E2) in MS-018-A.
Pin_Center_Distance = [0.541, 0.541]; // [0:0.001:300]

// Minimum distance from the bottom of a pin to the bottom of the package.
Pin_To_Body_Height = 0.020; // 0.001

use <tray.scad>

/* [Hidden] */
$fs = 0.01;

Inch_To_mm = 25.4;

Package_Size_mm = Package_Size * Inch_To_mm;
Pin_Center_Distance_mm = Pin_Center_Distance * Inch_To_mm;
Pin_To_Body_Height_mm = Pin_To_Body_Height * Inch_To_mm;

Tray(
    well_content_size = Package_Size_mm,
    tab_text = Tab_Text
) PLCC_Well();

module PLCC_Well() {
    linear_extrude(height = Pin_To_Body_Height_mm) 
    polygon(
        points = [
            [
                (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x),
                (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y)
            ],
            [
                Package_Size_mm.x - (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x),
                (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y)
            ],
            [
                Package_Size_mm.x - (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x),
                Package_Size_mm.y - (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y),
            ],
            [
                (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x),
                Package_Size_mm.y - (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y),
            ],

            [
                (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x) + 0.5,
                (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y) + 0.5
            ],
            [
                Package_Size_mm.x - (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x) - 0.5,
                (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y) + 0.5
            ],
            [
                Package_Size_mm.x - (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x) - 0.5,
                Package_Size_mm.y - (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y) - 0.5,
            ],
            [
                (Package_Size_mm.x - 2*Pin_Center_Distance_mm.x) + 0.5,
                Package_Size_mm.y - (Package_Size_mm.y - 2*Pin_Center_Distance_mm.y) - 0.5,
            ],
        ],
        paths = [
            [0, 1, 2, 3],
            [4, 5, 6, 7]
        ]
    );
}
