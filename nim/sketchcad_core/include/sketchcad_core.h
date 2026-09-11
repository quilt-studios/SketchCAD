#pragma once
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SketchCADPoint3 {
    double x;
    double y;
    double z;
} SketchCADPoint3;

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
uint32_t sketchcad_comfortable_stair_count(double total_rise, double preferred_rise);
double sketchcad_rectangle_area(double length, double width);
double sketchcad_rectangle_perimeter(double length, double width);
double sketchcad_slab_volume(double length, double width, double thickness);
double sketchcad_wall_volume(
    double length, double height, double thickness, double openings_area);
double sketchcad_repeated_opening_area(double width, double height, uint32_t count);
uint32_t sketchcad_masonry_unit_count(
    double wall_volume, double unit_volume, double waste_percent);
uint32_t sketchcad_tile_count(
    double area, double tile_length, double tile_width, double waste_percent);
double sketchcad_paint_volume(double area, double coverage_per_litre, uint32_t coats);
double sketchcad_strip_footing_volume(double length, double width, double depth);
double sketchcad_rectangular_column_volume(double width, double depth, double height);
double sketchcad_beam_volume(double length, double width, double height);
double sketchcad_circular_column_volume(double diameter, double height);
uint32_t sketchcad_downpipe_count(double roof_perimeter, double maximum_spacing);
double sketchcad_triangle_area(double base, double height);
double sketchcad_circle_area(double diameter);
double sketchcad_circle_circumference(double diameter);
double sketchcad_trapezoid_area(double parallel_a, double parallel_b, double height);
double sketchcad_room_volume(double length, double width, double height);
double sketchcad_skirting_length(double length, double width, double doorway_width);
double sketchcad_excavation_volume(double length, double width, double depth);
double sketchcad_backfill_volume(double excavation, double occupied_volume);
double sketchcad_ramp_slope_percent(double rise, double run);
double sketchcad_stair_angle_degrees(double total_run, double total_rise);
double sketchcad_handrail_length(double total_run, double total_rise, uint32_t sides);
double sketchcad_rainwater_volume(double roof_area, double rainfall_millimetres);
double sketchcad_thermal_transmittance(double thermal_resistance);
double sketchcad_fabric_heat_loss(double area, double u_value, double temperature_difference);
double sketchcad_ventilation_flow(double room_volume, double air_changes_per_hour);
double sketchcad_daylight_ratio(double window_area, double floor_area);
uint32_t sketchcad_occupancy_capacity(double usable_area, double area_per_person);
uint32_t sketchcad_parking_space_count(double usable_area, double area_per_space);
double sketchcad_reinforcement_mass(double length, double diameter, double density);
double sketchcad_pipe_internal_volume(double inner_diameter, double length);
double sketchcad_duct_surface_area(double width, double height, double length);
uint32_t sketchcad_ceiling_panel_count(double area, double panel_area);
double sketchcad_gutter_length(double building_length, uint32_t eaves);
double sketchcad_roof_overhang_area(
    double building_length, double building_width, double overhang);
double sketchcad_insulation_volume(double area, double thickness);
int sketchcad_point3_add(
    const SketchCADPoint3* left, const SketchCADPoint3* right, SketchCADPoint3* output);
int sketchcad_point3_subtract(
    const SketchCADPoint3* left, const SketchCADPoint3* right, SketchCADPoint3* output);
int sketchcad_point3_scale(
    const SketchCADPoint3* vector, double factor, SketchCADPoint3* output);
int sketchcad_point3_dot(
    const SketchCADPoint3* left, const SketchCADPoint3* right, double* output);
int sketchcad_point3_cross(
    const SketchCADPoint3* left, const SketchCADPoint3* right, SketchCADPoint3* output);
double sketchcad_point3_length(const SketchCADPoint3* vector);
double sketchcad_point3_distance(const SketchCADPoint3* left, const SketchCADPoint3* right);
int sketchcad_point3_normalize(const SketchCADPoint3* vector, SketchCADPoint3* output);
int sketchcad_point3_lerp(const SketchCADPoint3* start_point,
                          const SketchCADPoint3* end_point,
                          double amount,
                          SketchCADPoint3* output);
int sketchcad_point3_rotate_z(
    const SketchCADPoint3* point, double angle_degrees, SketchCADPoint3* output);

#ifdef __cplusplus
}
#endif
