using libx;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateProxy : MonoBehaviour
{
    [SerializeField] private bool development;
    [SerializeField] private GameObject root;
    // Start is called before the first frame update
    void Start()
    {
        if(development)
        {
            Assets.runtimeMode = false;
        }
        else
        {
            Assets.runtimeMode = true;
        }
        StartCoroutine(Load());
    }

    IEnumerator Load()
    {
        /// 初始化
        var init = Assets.Initialize();
        yield return init;
        if (string.IsNullOrEmpty(init.error))
        {
            Debug.LogError("初始化成功");
            init.Release();
            Init();
        }
        else
        {
            Debug.LogError("初始化失败");
        }
    }

    private void Init()
    {
        var assetPath = "Assets/Arts/ui/panel/StartPanel.prefab";
        Assets.LoadAssetAsync(assetPath, typeof(UnityEngine.Object)).completed += delegate (AssetRequest request)
        {
            if (!string.IsNullOrEmpty(request.error))
            {
                Debug.LogError(request.error);
                return;
            }
            GameObject go = (GameObject)Instantiate(request.asset);
            go.name = request.asset.name;
            go.transform.parent = root.transform;
            go.transform.localPosition = Vector3.zero;
            /// 设置关注对象，当关注对象销毁时，回收资源
            request.Require(go);
            //Destroy(go, 3);
            /// 设置关注对象后，只需要释放一次 
            /// 这里如果之前没有调用 Require，下一帧这个资源就会被回收
            //request.Release();
        };
    }

    // Update is called once per frame
    void Update()
    {

    }
}
