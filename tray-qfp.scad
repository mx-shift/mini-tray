
/*
 * Mini JEDEC-style tray for packages conforming to JEDEC MS-029-A
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
Tab_Text = "QFP";

// (X, Y, Z) size (in mm) of package including body and pins. Labeled (D, E, A) in MS-029-A.
Package_Size = [30.35, 30.35, 4.57]; // [0:0.01:300]

// (X, Y) size (in mm) of body only (excluding pins). Labeled (D1, E1) in MS-029-A.
Body_Size = [28, 28]; // [0:0.01:300]

// Minimum distance (in mm) from body to first bend in pins. Labeled S in MS-029-A.
Body_To_Pin_Distance = 0.2; // 0.01

// Maximum distance from bottom of a pin to the bottom of the package. Labeled A1 in MS-029-A.
Pin_To_Body_Height = 0.5; // 0.01

use <tray.scad>

/* [Hidden] */
$fs = 0.01;

Tray(
    well_content_size = Package_Size,
    tab_text = Tab_Text
) QFP_Well();

module QFP_Well() {
    Package_To_Pin_Bend = [
        (Package_Size.x - Body_Size.x)/2 - Body_To_Pin_Distance,
        (Package_Size.y - Body_Size.y)/2 - Body_To_Pin_Distance,
    ];

    linear_extrude(height = Pin_To_Body_Height)
    polygon(
        points = [
            [
                Package_To_Pin_Bend.x,
                Package_To_Pin_Bend.y,
            ],
            [
                Package_Size.x - Package_To_Pin_Bend.x,
                Package_To_Pin_Bend.y,
            ],
            [
                Package_Size.x - Package_To_Pin_Bend.x,
                Package_Size.y - Package_To_Pin_Bend.y,
            ],
            [
                Package_To_Pin_Bend.x,
                Package_Size.y - Package_To_Pin_Bend.y,
            ],

            [
                Package_To_Pin_Bend.x + 0.5,
                Package_To_Pin_Bend.y + 0.5,
            ],
            [
                Package_Size.x - Package_To_Pin_Bend.x - 0.5,
                Package_To_Pin_Bend.y + 0.5,
            ],
            [
                Package_Size.x - Package_To_Pin_Bend.x - 0.5,
                Package_Size.y - Package_To_Pin_Bend.y - 0.5,
            ],
            [
                Package_To_Pin_Bend.x + 0.5,
                Package_Size.y - Package_To_Pin_Bend.y - 0.5,
            ],
        ],
        paths = [
            [0, 1, 2, 3],
            [4, 5, 6, 7]
        ]
    );
}
