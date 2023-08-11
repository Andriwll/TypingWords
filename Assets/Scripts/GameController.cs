using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum DifficultyLevel
{
    Fim,
    Facil,
    Normal,
    Dificil,
    Extremo
}

public class GameController : MonoBehaviour
{
    public Text inputText;
    public Text translationText;
    public Text scoreText;
    public Text currentWordText;
    public Text timerText; // Reference to TimerUI Text element
    public Text difficultyText; // Reference to Difficulty Text UI element
    private bool isGameActive = true; // Indicates whether the game is currently active

    public float initialTime; // Initial timer value in seconds
    private float currentTime; // Current timer value

    private DifficultyLevel currentDifficulty = DifficultyLevel.Facil;

    private string randomWord;
    private int score = 10;

    private void Start()
    {
        // Get the initial random word
        randomWord = RandomWordSelector.Instance.GetRandomWord();
        // Update current word text
        currentWordText.text = "Palavra: " + randomWord;
        // Call method to update translation based on the new random word
        UpdateTranslation(randomWord);
        //Update Difficulty
        UpdateDifficultyDisplay();
        // Verificar e definir a dificuldade inicial
        CheckScoreAndSetDifficulty();
        //Start Timer
        currentTime = initialTime;
        inputText.text = "";
        score = score - 10;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Backspace))
        {
            if (inputText.text.Length > 0)
            {
                inputText.text = inputText.text.Substring(0, inputText.text.Length - 1);
            }
        }
        else if (Input.GetKeyDown(KeyCode.Return))
        {
            currentTime = 10f;
            CheckMatchAndScore();
            CheckScoreAndSetDifficulty();
            inputText.text = "";
            // Get a new random word
            randomWord = RandomWordSelector.Instance.GetRandomWord();
            // Call method to update translation based on the new random word
            UpdateTranslation(randomWord);
        }
        else if (Input.inputString.Length > 0)
        {
            foreach (char c in Input.inputString)
            {
                if (char.IsLetter(c) || char.IsLetterOrDigit(c) && IsAccentuated(c))
                {
                    inputText.text += c;
                }
            }
        }

        Timer();
        ChangeInputTextColor();
    }

    private bool IsAccentuated(char c)
    {
        string accentuatedCharacters = "áéíóúàèìòùâêîôûãõñÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÑ";
        return accentuatedCharacters.Contains(c);
    }

    private void UpdateDifficultyDisplay()
    {
        difficultyText.text = "Dificuldade:\n" + currentDifficulty.ToString();
    }

    private void Timer()
    {
        if (isGameActive)
        {
            if (currentTime > 0f)
            {
                currentTime -= Time.deltaTime;
                // Display the timer in TimerUI Text element

                timerText.text = "Tempo:\n" + currentTime.ToString("F1");
            }
            else
            {
                // Timer has completed, perform actions here
                CheckScoreAndSetDifficulty();
                Debug.Log("Time's up!");
                CheckMatchAndScore();
                inputText.text = "";
                // Get a new random word
                randomWord = RandomWordSelector.Instance.GetRandomWord();
                // Call method to update translation based on the new random word
                UpdateTranslation(randomWord);
            }
        }
    }

    public void SetDifficulty(DifficultyLevel difficulty)
    {
        currentDifficulty = difficulty;

        // Update the timer duration based on difficulty
        switch (currentDifficulty)
        {
            case DifficultyLevel.Facil:
                initialTime = 10f;
                break;
            case DifficultyLevel.Normal:
                initialTime = 6f;
                break;
            case DifficultyLevel.Dificil:
                initialTime = 4f;
                break;
            case DifficultyLevel.Extremo:
                initialTime = 2f;
                break;
            case DifficultyLevel.Fim:
                OnFinishButtonClicked();
                break;
        }
        // Restart the timer with the new initial time
        currentTime = initialTime;

        // Update the difficulty display text
        UpdateDifficultyDisplay();
    }

    private void CheckScoreAndSetDifficulty()
    {
        if (score >= 3000)
        {
            SetDifficulty(DifficultyLevel.Extremo);
        }
        else if (score >= 2000)
        {
            SetDifficulty(DifficultyLevel.Dificil);
        }
        else if (score >= 1000)
        {
            SetDifficulty(DifficultyLevel.Normal);
        }
        else if (score < 1000 && score > 0)
        {
            SetDifficulty(DifficultyLevel.Facil);
        }
        else if (score < 1)
        {
            SetDifficulty(DifficultyLevel.Fim);
        }
    }

    private void CheckMatchAndScore()
    {
        if (inputText.text.Trim().ToLower() == randomWord.Trim().ToLower())
        {
            // Get the correct translation
            string correctTranslation = TranslationManager.Instance.GetTranslation(randomWord);
            if (correctTranslation == inputText.text.Trim().ToLower())
            {
                // Update the translation display
                translationText.text = "Tradução:\n" + correctTranslation;
            }

            // Add 100 points for a correct match
           
            score += 100;
             CheckScoreAndSetDifficulty(); // Verificar e atualizar a dificuldade
            Debug.Log("Pontuação: " + score);
            scoreText.text = "Pontuação: " + score;
        }
        else
        {
            // Get the correct translation
            string correctTranslation = TranslationManager.Instance.GetTranslation(randomWord);
            if (correctTranslation == inputText.text.Trim().ToLower())
            {
                // Update the translation display
                translationText.text = "Tradução:\n" + correctTranslation;
            }

            // Subtract 100 points for a correct match

            score = 0;
            CheckScoreAndSetDifficulty(); // Verificar e atualizar a dificuldade
            Debug.Log("Pontuação: " + score);
            scoreText.text = "Pontuação: " + score;
        }
    }

    private void ChangeInputTextColor()
    {
        string input = inputText.text.Trim().ToLower();
        string word = randomWord.Trim().ToLower();

        if (input == word)
        {
            inputText.color = Color.Lerp(Color.white, Color.green, 0.5f); // Meio verde
        }
        else if (word.StartsWith(input))
        {
            inputText.color = Color.Lerp(Color.white, Color.white, 0.5f); // Meio branco
        }
        else
        {
            inputText.color = Color.Lerp(Color.white, Color.red, 0.5f); // Meio vermelho
        }
    }

    private void UpdateTranslation(string originalWord)
    {
        if (TranslationManager.Instance != null)
        {
            string translation = TranslationManager.Instance.GetTranslation(originalWord);
            translationText.text = "Tradução:\n" + translation;
            // Update current word text
            currentWordText.text = "Palavra:\n" + originalWord;
        }
    }

    public void FinishGame()
    {
        print("Fim porra: " + score);
    }

    public void OnFinishButtonClicked()
    {
        isGameActive = false; // Stop the game timer
        FinishGame(); // Call the FinishGame method to handle end-of-game actions
    }
}
