# Physically Based Parallax Occlusion Mapping with Self-Shadowing in Unity

This project demonstrates Physically Based Parallax Occlusion Mapping (POM) with self-shadowing in **Unity's Built-In Render Pipeline using HLSL**. It compares three shading models: the Unity Standard Shader, Blinn-Phong (Empirical), and Cook-Torrance with Oren-Nayar (Physically Based). Each of these models also includes a simpler counterpart utilizing basic parallax mapping, highlighting the differences in depth perception and realism.

This page is designed to help solidify one's understanding of parallax mapping and explore the advancements that enhance realism while maintaining a relatively low computational cost.

<p align="center">
  <a href="https://youtu.be/XEOFwgZYHSo">
    <img src="https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/GIF.gif" alt="Example showcase GIF" />
  </a>
  <br>
  <em>Click to watch the showcase on YouTube</em>
</p>

## Table of Contents

- [Parallax Mapping](#parallax-mapping)
- [Parallax Occlusion Mapping](#parallax-occlusion-mapping)
- [Self Shadowing](#self-shadowing)
- [Shader Parameters](#shader-parameters)
- [Performance Considerations](#performance-considerations)
- [Future Improvements](#future-improvements)
- [Credits](#credits)
- [License](#license)

## Parallax Mapping

### How It Works  

Have you ever seen those mind-bending optical illusion street art that turns a flat sidewalk into a deep dark abyss? From the right angle, it feels like you are standing on the edge of a cliff, staring into the gaping unknown. You might even ask a friend to hold the camera while you carefully step on the painted "debris" to strike a frightened pose for your Instagram. This is the concept behind parallax mapping - shifting textures to trick your eyes into seeing real depth.

<details>
  <summary>Expand to view the images</summary>
    
  | **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
  |--------------------------|--------------------------------------|
  | ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20BP%20-%20Simple%20UP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20CT%20-%20Simple%20UP.jpg) |
  
</details>

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

<details>
  <summary>Expand to view the images</summary>

| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20BP%20-%20Simple%20SIDE.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Simple/Brick%20CT%20-%20Simple%20SIDE.jpg) |

</details>

---
## Parallax Occlusion Mapping

### How It Works  

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

<details>
  <summary>Expand to view the images</summary>
  
| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20BP%20-%20Steep%20UP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20CT%20-%20Steep%20UP.jpg) |

</details>

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

<details>
  <summary>Expand to view the images</summary>

| **Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20BP%20-%20Steep%20SIDE.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/POM/Brick%20CT%20-%20Steep%20SIDE.jpg) |

</details>

--- 
## Self Shadowing

### How It Works  

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sodales scelerisque risus. Proin ullamcorper cursus arcu, imperdiet semper libero. Sed volutpat ante quis enim elementum, id vulputate quam gravida. Aliquam ullamcorper posuere sapien in dapibus. Proin laoreet odio a nulla fringilla gravida. Quisque vel felis sit amet dui ultricies blandit a eget lectus. Mauris sapien eros, consequat non felis ut, mattis vestibulum mi. Maecenas urna lectus, cursus eget laoreet vel, accumsan molestie mauris. Quisque sed nisl convallis, commodo lectus sit amet, pretium odio. Aenean vitae sapien et enim hendrerit ultricies quis nec ligula. Praesent eu risus nec diam volutpat suscipit.

<details>
  <summary>Expand to view the images</summary>

|**Blinn-Phong (Empirical)** | **Cook-Torrance + Oren-Nayar (Physically Based)** |
|--------------------------|--------------------------------------|
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20BP%20-%20Shadow%20UP.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20CT%20-%20Shadow%20UP.jpg) |
| ![Blinn-Phong](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20BP%20-%20Shadow%20SIDE.jpg) | ![CTON](https://github.com/bentoBAUX/Physically-Based-Parallax-Occlusion-Mapping-with-Self-Shadowing/blob/master/Assets/Images/Comparison/Self%20Shadow/Brick%20CT%20-%20Shadow%20SIDE.jpg) |

</details>

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

- Joey de Vries for his insightful tutorial on [LearnOpenGL](https://learnopengl.com/Advanced-Lighting/Parallax-Mapping), which provided a strong foundation for this project’s development.
- Rabbid76 on [StackOverflow](https://stackoverflow.com/questions/55089830/adding-shadows-to-parallax-occlusion-map) for the tutorial on self shadowing for parallax mapping.

## License  

This project is licensed under the **MIT License** – feel free to use, modify, and improve it! 🎨  

