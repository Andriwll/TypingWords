using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TranslationManager : MonoBehaviour
{
    public TextAsset translationFile;
    private Dictionary<string, string> translationMap = new Dictionary<string, string>();

    public static TranslationManager Instance;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;

        string[] lines = translationFile.text.Split('\n');
        foreach (string line in lines)
        {
            string[] parts = line.Split('=');
            if (parts.Length == 2)
            {
                string originalWord = parts[0].Trim();
                string translatedWord = parts[1].Trim();
                translationMap.Add(originalWord, translatedWord);
            }
        }
    }

    public string GetTranslation(string originalWord)
    {
        if (translationMap.TryGetValue(originalWord, out string translatedWord))
        {
            return translatedWord;
        }
        else
        {
            Debug.LogWarning("Translation not found for: " + originalWord);
            return string.Empty;
        }
    }
}
