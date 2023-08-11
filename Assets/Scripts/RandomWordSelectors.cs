using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomWordSelector : MonoBehaviour
{
    public TextAsset wordFile;

    private string[] words;

    public static RandomWordSelector Instance;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;

        words = wordFile.text.Split('\n');
    }

    public string GetRandomWord()
    {
        return words[Random.Range(0, words.Length)].Trim();
    }
}
