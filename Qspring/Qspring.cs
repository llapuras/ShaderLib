using System.Collections;
using System.Collections.Generic;
using UnityEngine;

interface IElastic03
{
    void OnElastic03(RaycastHit2D hit);
}

[RequireComponent(typeof(SpriteRenderer))]
public class Qspring : MonoBehaviour
{
    private static int s_pos, s_time;
    public Material mat;

    public Shader sh;
    public float frequency = 11;
    public float duration = 2;

    private SpriteRenderer mesh;
    private void Start()
    {
        mat = new Material(sh);
        mesh = GetComponent<SpriteRenderer>();
        mesh.material = mat;
        mat.name = gameObject.name;

    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit2D hit = Physics2D.GetRayIntersection(Camera.main.ScreenPointToRay(Input.mousePosition));

            if (hit.collider == GetComponent<BoxCollider2D>())  //单次点击仅被点击物跳动
            //if (hit.collider != null)  //单次点击全员跳动，很好玩...
            {
                Debug.Log("object clicked: " + hit.collider.name);
                OnElastic(hit);
                GetComponent<AudioSource>().Play();
            }
        }
    }

    public void OnElastic(RaycastHit2D hit)
    {
        //反弹的坐标 (InverseTransformPoint 把世界坐标转为到自身坐标的位置)
        Vector4 v = transform.InverseTransformPoint(hit.point);

        //受影响顶点范围的半径
        v.w = 1f;
        mat.SetVector("_Position", v);
        mat.SetFloat("_Frequency", frequency);
        mat.SetFloat("_Duration", duration);
        //重置时间（把shader 的中时间函数以现在的为基础计时）
        mat.SetFloat("_PointTime", Time.time);
    }
}