# Physically Based Parallax Occlusion Mapping with Self-Shadowing in Unity  

> **A high-quality Parallax Occlusion Mapping (POM) shader for Unity, featuring self-shadowing and a physically based shading model using Cook-Torrance for specular reflection and Oren-Nayar for diffuse lighting.**  

![Demo GIF](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/GIF.gif)  
*Example of the shader in action*  

---

## Features  

- **Parallax Occlusion Mapping (POM)** – Adds realistic depth without extra geometry.  
- **Self-Shadowing** – Objects cast accurate depth shadows inside the texture.  
- **Physically Based Lighting** – Uses Cook-Torrance (specular) + Oren-Nayar (diffuse).  
- **Shader Comparison** – Unity Standard vs. Blinn-Phong vs. Physically Based Cook-Torrance.  
- **Optimized for Unity** – Works in the **Built-in Render Pipeline**.  


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


## Video Showcase  

**Watch the full demo here:** [YouTube Link](https://your-video-link)  


## Future Improvements  

- Add support for **dynamic tessellation**.  
- Improve self-shadowing accuracy for extreme angles.  
- Optimize performance with **adaptive sampling techniques**.  


## Credits  

- **Developed by:** [Your Name](https://github.com/yourusername)  
- Inspired by **Unity’s built-in shaders** & **academic research on PBR shading models**.  


## License  

This project is licensed under the **MIT License** – feel free to use, modify, and improve it! 🎨  

