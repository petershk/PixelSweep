extern number time;

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
    float pulse = 0.5 + 0.5 * sin(time * 2.0);
    return vec4(pulse, 0.0, 0.0, 1.0);
}