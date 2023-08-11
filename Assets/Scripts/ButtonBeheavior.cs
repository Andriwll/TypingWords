using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class ButtonBehavior : MonoBehaviour, IPointerClickHandler, IPointerEnterHandler, IPointerExitHandler
{
    private Vector3 originalScale;
    private Button button;
    private bool isClicked = false;
    private bool isMouseOver = false;

    private void Start()
    {
        originalScale = transform.localScale;
        button = GetComponent<Button>();
    }

    private void Update()
    {
        if (isClicked)
        {
            Vector3 targetScale = originalScale * 0.5f;
            transform.localScale = Vector3.Lerp(transform.localScale, targetScale, Time.deltaTime * 5f);
        }
        else if (isMouseOver)
        {
            Vector3 targetScale = originalScale * 0.9f;
            transform.localScale = Vector3.Lerp(transform.localScale, targetScale, Time.deltaTime * 5f);
        }
        else
        {
            transform.localScale = Vector3.Lerp(transform.localScale, originalScale, Time.deltaTime * 5f);
        }
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        isClicked = true;
        Invoke("ResetButtonState", 0.1f);
    }

    private void ResetButtonState()
    {
        isClicked = false;
    }

   public void OnPointerEnter(PointerEventData eventData)
   {
       isMouseOver = true;
       print(isMouseOver);
   }

  public void OnPointerExit(PointerEventData eventData)
   {
       isMouseOver = false;
       print(isMouseOver);
   }
}
