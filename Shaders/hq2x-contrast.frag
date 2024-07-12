uniform sampler2D baseMap;

void main ()
{
  vec3 c11 = texture2D(baseMap, gl_TexCoord[0].xy).xyz;  
  vec3 col = vec3(c11);
  float gray = (col.r + col.g + col.b) / 3.0;
  vec3 grayscale = vec3(gray);

  vec3 color_b6924a = mix(vec3(0.814, 0.683, 0.290), vec3(0,0,0), min(1.0-(gray*2.0), 1.0));

  gl_FragColor = vec4(mix(grayscale, color_b6924a, 0.6), 1.0);
}