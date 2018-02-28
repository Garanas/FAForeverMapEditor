﻿// ***************************************************************************************
// * SCmap editor
// * Set Unity objects and scripts using data loaded from Scm
// ***************************************************************************************

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class ScmapEditor : MonoBehaviour
{

	static int heightsLength;
	static float[,] heights = new float[1, 1];

	public static void ApplyHeightmap(bool delayed = true)
	{
		if (delayed)
			Current.Data.SetHeightsDelayLOD(0, 0, heights);
		else
		{
			Current.Data.SetHeights(0, 0, heights);
			Current.Teren.Flush();
		}
	}

	public static void SetHeights(int X, int Y, float[,] values, bool delayed = true)
	{
		int width = values.GetLength(1);
		int height = values.GetLength(0);

		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				heights[X + x, Y + y] = values[x, y];
			}
		}

		if (delayed)
			Current.Data.SetHeightsDelayLOD(X, Y, values);
		else
		{
			Current.Data.SetHeights(X, Y, values);
			Current.Teren.Flush();
		}
	}

	public static void ApplyChanges(int X, int Y)
	{
		int x = 0;
		int y = 0;
		for (x = 0; x < LastGetWidth; x++)
		{
			for (y = 0; y < LastGetHeight; y++)
			{
				int hx = Y + x;
				int hy = X + y;
				if (hx >= heightsLength || hy >= heightsLength)
					continue;

				heights[hx, hy] = ReturnValues[x, y];
			}
		}

		if(X + ReturnValues.GetLength(0) >= heightsLength || Y + ReturnValues.GetLength(1) >= heightsLength)
		{
			ApplyHeightmap(true);
		}
		else
			Current.Data.SetHeightsDelayLOD(X, Y, ReturnValues);
		//ApplyHeightmap();
	}

	public static void SetHeight(int x, int y, float value)
	{
		heights[x, y] = value;
	}



	public static float GetHeight(int x, int y)
	{
		return heights[x, y];
	}

	public static float[,] ReturnValues;
	public static int LastGetWidth = 0;
	public static int LastGetHeight = 0;
	public static float[,] GetValues(int X, int Y, int Width, int Height)
	{
		if(Width != LastGetWidth || Height != LastGetHeight)
		{
			ReturnValues = new float[Width, Height];
			LastGetWidth = Width;
			LastGetHeight = Height;
		}

		int x = 0;
		int y = 0;

		for(x = 0; x < LastGetWidth; x++)
		{
			for(y = 0; y < LastGetHeight; y++)
			{
				int hx = Y + x;
				int hy = X + y;
				if (hx >= heightsLength || hy >= heightsLength)
					continue;

				ReturnValues[x, y] = heights[hx, hy];
			}
		}

		//ReturnValues = Current.Data.GetHeights(X, Y, Width, Height);

		return ReturnValues;
	}
}