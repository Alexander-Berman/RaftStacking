//## ---- END CONSTANTS---- ##//
// all units in MM

//object information
//   hand-enter size of object, as OpenSCAD cannot calculate this
STL_FILE = "<path to stl file>";
Object_Size_X = 11.032; //size in X
Object_Size_Y = 11.032; //size in Y
Object_Size_Z = 33.771; //size in Z
X_Offset = -4.5; //offset to origin in X
Y_Offset = 3.5; //offset to origin in Y
Z_Offset = 0; //offset to origin in Z

//printer Volume information
Printer_X = 160;
Printer_Y = 160;
Printer_Z = 210;

//Boolean Variables for switching dual extruder or not
SEPARATE_FILES = false; //true for export two files, false for one big file
EXPORT_SUPPORT = true;  //only used if above is 'true': true for printing scaffold, false for the stl duplicates

//Spacing information (keep defaults if unsure)
SIDE_PADDING = 5; //amount of XY space between prints
INNER_WALLS = true; //include inner walls if True (good for objects that dont support the raft
WALL_SIZE = 0.25;//thickness of the walls
PERIMETER_SIZE = 1.0;//thickness of outer perimeter (generally good to make thicker to support rafts)

TOP_PADDING = 0.4; //space above the model and the raft
BOTTOM_PADDING = 0.25; //space below the model and the raft
RAFT_THICKNESS = 1.5; //thickness of the raft. Thicker makes less prone to it falling apart under weight, but more time/material

MANUAL_GRID = false; //if 'false': generates grid based on available printer volume. If 'true': uses numbers below
number_x=7; //number of items in X direction
number_y=7; //number of items in Y direction
number_z=2; //number of items 'stacked' in Z

//## ---- END CONSTANTS---- ##//

// GENERATING PLACEMENT INFORMATION
if(!MANUAL_GRID){
  number_x = floor(Printer_X/(Object_Size_X + SIDE_PADDING));
  number_y = floor(Printer_Y/(Object_Size_Y + SIDE_PADDING));
  number_z = floor(Printer_Z/(Object_Size_Z + TOP_PADDING + RAFT_THICKNESS + BOTTOM_PADDING));
}
echo(number_x,number_y,number_z);

//Placing STLs
translate([X_Offset,Y_Offset,Z_Offset]) cube([.1,.1,number_z*(Object_Size_Z+TOP_PADDING+BOTTOM_PADDING+RAFT_THICKNESS)]);//optional cube to trick Cura to thinking all objects are connected
for (x = [0:number_x-1]){
    for (y = [0:number_y-1]){
        for (z = [0:number_z-1]){
            translate([(Object_Size_X+SIDE_PADDING+WALL_SIZE)*x,(Object_Size_Y+SIDE_PADDING+WALL_SIZE)*y,0]){
                z_height = (Object_Size_Z+BOTTOM_PADDING+TOP_PADDING+RAFT_THICKNESS)*z;
                if(!SEPARATE_FILES || !EXPORT_SUPPORT){
                    translate([X_Offset,Y_Offset,Z_Offset+z_height]) import(STL_FILE);
                } 
                if (z>0){
                    if(!SEPARATE_FILES || EXPORT_SUPPORT){
                        translate([0,0,Object_Size_Z*z + BOTTOM_PADDING*(z-1) + TOP_PADDING*z]) cube([Object_Size_X+SIDE_PADDING+WALL_SIZE,Object_Size_Y+SIDE_PADDING+WALL_SIZE,RAFT_THICKNESS],center=true);
                    }
                }
            }
           if(!SEPARATE_FILES || EXPORT_SUPPORT){
               //make inner walls (optional but recommended)
                if(INNER_WALLS && z<number_z-1){
                    translate([(Object_Size_X+SIDE_PADDING+WALL_SIZE)*x,(Object_Size_Y+SIDE_PADDING+WALL_SIZE)*y,(Object_Size_Z+BOTTOM_PADDING+TOP_PADDING+RAFT_THICKNESS)*z]){
                        //X
                        if(x>0){
                            translate([-0.5*Object_Size_X-SIDE_PADDING/2,-0.5*Object_Size_Y,0]) cube([WALL_SIZE,Object_Size_Y,Object_Size_Z+TOP_PADDING+BOTTOM_PADDING]);
                        }
                        //Y
                        if(y>0){
                            translate([-0.5*Object_Size_X,-0.5*Object_Size_Y-SIDE_PADDING,0]) cube([Object_Size_X,WALL_SIZE,Object_Size_Z+TOP_PADDING+BOTTOM_PADDING]);
                        }   
                    }
                }  
            }   
        }
    }
}

//create outer perimeter

if(!SEPARATE_FILES || EXPORT_SUPPORT){
    translate([-0.5*Object_Size_X-SIDE_PADDING/2-PERIMETER_SIZE,-0.5*Object_Size_Y-SIDE_PADDING/2-PERIMETER_SIZE,0]) difference(){
        cube([(Object_Size_X+SIDE_PADDING)*(number_x)+2*PERIMETER_SIZE,(Object_Size_Y+SIDE_PADDING)*(number_y)+2*PERIMETER_SIZE,(Object_Size_Z+TOP_PADDING+RAFT_THICKNESS)*(number_z-1)+BOTTOM_PADDING*(number_z-2)]);
        
        translate([PERIMETER_SIZE/2,PERIMETER_SIZE/2,-1]) cube([(Object_Size_X+SIDE_PADDING)*(number_x),(Object_Size_Y+SIDE_PADDING)*(number_y),(Object_Size_Z+TOP_PADDING+RAFT_THICKNESS)*(number_z-1)+BOTTOM_PADDING*(number_z-2)+1]);
    }
    cube([.001,.001,.001]);
}


