#pragma once
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

uint32_t sketchcad_fence_bay_count(double length, double maximum_spacing);
uint32_t sketchcad_fence_post_count(double length, double maximum_spacing);
uint32_t sketchcad_railing_post_count(double width, double depth, double maximum_spacing);
double sketchcad_stair_going(double total_run, double total_rise, uint32_t steps);
double sketchcad_stair_rise(double total_run, double total_rise, uint32_t steps);
double sketchcad_roof_rafter_length(double span, double rise);
double sketchcad_roof_pitch_degrees(double span, double rise);
double sketchcad_gable_roof_area(double length, double span, double rise);
double sketchcad_wall_net_area(double length, double height, double openings_area);
uint32_t sketchcad_material_unit_count(
    double area, double coverage_per_unit, double waste_percent);
double sketchcad_ramp_length(double rise, double maximum_gradient);

#ifdef __cplusplus
}
#endif
