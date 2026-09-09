[gd_scene load_steps=6 format=3 uid="uid://splash_screen_01"]

[ext_resource type="Script" path="res://scripts/menus/SplashScreen.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/app_icon/Gasy_Tsara.png" id="2_logo"]

[sub_resource type="ParticleProcessMaterial" id="ParticleMat_sparkle"]
emission_shape = 1
emission_sphere_radius = 80.0
direction = Vector3(0, -1, 0)
spread = 45.0
initial_velocity_min = 20.0
initial_velocity_max = 60.0
gravity = Vector3(0, -20, 0)
scale_min = 0.8
scale_max = 2.5
color = Color(0.4, 0.8, 1.0, 0.7)

[sub_resource type="QuadMesh" id="ParticleMesh_dot"]
size = Vector2(4, 4)

[node name="SplashScreen" type="CanvasLayer"]
layer = 10
script = ExtResource("1_script")

[node name="Background" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.05, 0.05, 0.08, 1.0)
mouse_filter = 2

[node name="CenterContainer" type="CenterContainer" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0

[node name="VBox" type="VBoxContainer" parent="CenterContainer"]
alignment = 1
theme_override_constants/separation = 24

[node name="Logo" type="TextureRect" parent="CenterContainer/VBox"]
custom_minimum_size = Vector2(320, 320)
texture = ExtResource("2_logo")
expand_mode = 1
stretch_mode = 5
modulate = Color(1, 1, 1, 0)

[node name="Tagline" type="Label" parent="CenterContainer/VBox"]
text = "Gasy Tsara – Tondraka ny Nosy"
horizontal_alignment = 1
modulate = Color(1, 1, 1, 0)
theme_override_colors/font_color = Color(0.75, 0.92, 1.0, 1.0)
theme_override_font_sizes/font_size = 22

[node name="Particles" type="GPUParticles2D" parent="."]
position = Vector2(640, 360)
amount = 60
lifetime = 2.5
process_material = SubResource("ParticleMat_sparkle")
draw_pass_1 = SubResource("ParticleMesh_dot")
emitting = true

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
