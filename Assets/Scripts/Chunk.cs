using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chunk : MonoBehaviour
{
    public int width = 10;
    public int height = 10;
    public float size = 1;

    public void RefreshMesh()
    {
        var filter = GetComponent<MeshFilter>();

        var mesh = new Mesh();
        mesh.name = "chunk";

        Vector3[] vertices = new Vector3[(width + 1) * (height + 1)];
        for (int i = 0; i <= width; i++)
        {
            for (int j = 0; j <= height; j++)
            {
                vertices[j * (width + 1) + i] = new Vector3(i * size, 0, j * size);
            }
        }

        List<int> triangles = new List<int>();
        int xcount = width + 1;
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                triangles.Add(j * xcount + i);
                triangles.Add((j + 1) * xcount + i);
                triangles.Add((j + 1) * xcount + i + 1);

                triangles.Add(j * xcount + i);
                triangles.Add((j + 1) * xcount + i + 1);
                triangles.Add(j * xcount + i + 1);
            }
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles.ToArray();
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();
        mesh.RecalculateTangents();

        filter.mesh = mesh;
    }

    private void OnValidate()
    {
        RefreshMesh();
    }
}