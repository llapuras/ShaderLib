using UnityEngine;
using System;

[ExecuteInEditMode]
public class ScreenBlur : MonoBehaviour
{

	[Range(1, 16)]
	public int iterations = 4;

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{

		int width = source.width / 2;
		int height = source.height / 2;
		RenderTextureFormat format = source.format;

		RenderTexture currentDestination = RenderTexture.GetTemporary(width, height, 0, format);

		Graphics.Blit(source, currentDestination);
		RenderTexture currentSource = currentDestination;
		Graphics.Blit(currentSource, destination);
		RenderTexture.ReleaseTemporary(currentSource);

		for (int i = 1; i < iterations; i++)
		{
			width /= 2;
			height /= 2;
			if (height < 2)
			{
				break;
			}
			currentDestination = RenderTexture.GetTemporary(width, height, 0, format);
			Graphics.Blit(currentSource, currentDestination);
			RenderTexture.ReleaseTemporary(currentSource);
			currentSource = currentDestination;
		}

		Graphics.Blit(currentSource, destination);

		RenderTexture.ReleaseTemporary(currentSource);
	}
}