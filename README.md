# Physically Based Parallax Occlusion Mapping with Self-Shadowing in Unity  

## Table of Contents

- [Overview](#overview)
- [Parallax Mapping](#parallax-mapping)
- [Parallax Occlusion Mapping](#parallax-occlusion-mapping)
- [Self Shadowing](#self-shadowing)
- [Shader Parameters](#shader-parameters)
- [Performance Considerations](#performance-considerations)
- [Future Improvements](#future-improvements)
- [Credits](#credits)
- [License](#license)

---
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

---

## Parallax Mapping

### How It Works  

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20BP%20-%20Simple%20UP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20CT%20-%20Simple%20UP.jpg) |

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20BP%20-%20Simple%20SIDE.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20CT%20-%20Simple%20SIDE.jpg) |

---
## Parallax Occlusion Mapping

### How It Works  

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20BP%20-%20Steep%20UP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20CT%20-%20Steep%20UP.jpg) |

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20BP%20-%20Steep%20SIDE.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20CT%20-%20Steep%20SIDE.jpg) |

--- 
## Self Shadowing

### How It Works  

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

|**Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20BP%20-%20Shadow%20UP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20CT%20-%20Shadow%20UP.jpg) |
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20BP%20-%20Shadow%20SIDE.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20CT%20-%20Shadow%20SIDE.jpg) |


---


### Shader Parameters  
| **Parameter** | **Description** |
|--------------|----------------|
| `_HeightScale` | Controls the depth intensity of POM |
| `_NumberOfLayers` | Adjusts the precision of parallax calculation |
| `_Metallic` | Controls how metallic the surface appears |
| `_Roughness` | Affects surface roughness and light scattering |
| `_NormalStrength` | Strength of normal map details |

---
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

