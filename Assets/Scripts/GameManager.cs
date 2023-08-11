using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    public void EndGame()
    {
        // Aqui você pode adicionar a lógica para finalizar o jogo, como exibir uma tela de pontuação final, voltar para o menu principal, etc.
        // Implemente a lógica de finalização do jogo conforme necessário.
        Application.Quit();
    }

    public void Menu(){
        SceneManager.LoadScene("MainMenu"); // Exemplo: volta para a cena do menu principal
    }
}

