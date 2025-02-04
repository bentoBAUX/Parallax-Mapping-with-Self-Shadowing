# Physically Based Parallax Occlusion Mapping with Self-Shadowing in Unity  

<p align="center">
  <a href="https://youtu.be/GjTtb7B6h1A">
    <img src="https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/GIF.gif" alt="Example showcase GIF" />
  </a>
  <br>
  <em>Click to watch the showcase on YouTube</em>
</p>

## Overview
This project demonstrates **Physically Based Parallax Occlusion Mapping (POM)** with self-shadowing in Unity's Built-In Render Pipeline using HLSL.

It compares three shading models: the Unity Standard Shader, Blinn-Phong (Empirical), and Cook-Torrance with Oren-Nayar (Physically Based). Each of these models also includes a simpler counterpart utilizing basic parallax mapping, highlighting the differences in depth perception and realism.

This page is designed to help solidify one's understanding of parallax mapping and explore the advancements that enhance realism while maintaining a relatively low computational cost.


## Side-by-Side Shader Comparison  

| **Unity Standard Shader** | **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------|--------------------------------------|
| ![Unity Standard](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Brick%20Unity.jpg) | ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Brick%20BP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Brick%20CT.jpg) |


## How It Works  

### **What is Parallax Occlusion Mapping?**  
Parallax Occlusion Mapping (POM) is a technique that simulates depth on flat surfaces using a **height map**. Unlike normal mapping, which only affects lighting, **POM actually shifts texture coordinates** based on the viewing angle, creating a **3D illusion**.  

### **How Self-Shadowing Works**  
Self-shadowing allows surfaces to **cast shadows onto themselves**, making depth features more realistic. This shader calculates occlusion by **tracing the light direction through the height map**.  


## Customization  

### Shader Parameters  
| **Parameter** | **Description** |
|--------------|----------------|
| `_HeightScale` | Controls the depth intensity of POM |
| `_NumberOfLayers` | Adjusts the precision of parallax calculation |
| `_Metallic` | Controls how metallic the surface appears |
| `_Roughness` | Affects surface roughness and light scattering |
| `_NormalStrength` | Strength of normal map details |


## Performance Considerations  

- **Use lower `NumberOfLayers` for better performance.**  
- **Steep angles require more samples; consider LOD adjustments.**  
- **Avoid overusing self-shadowing on high-performance constraints.**  

## Future Improvements  

- Add support for **dynamic tessellation**.  
- Improve self-shadowing accuracy for extreme angles.  
- Optimize performance with **adaptive sampling techniques**.  


## Credits  

- **Developed by:** [Your Name](https://github.com/yourusername)  
- Inspired by **Unity’s built-in shaders** & **academic research on PBR shading models**.  


## License  

This project is licensed under the **MIT License** – feel free to use, modify, and improve it! 🎨  

