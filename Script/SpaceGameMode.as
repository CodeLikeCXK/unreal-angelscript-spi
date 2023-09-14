event void FUpdateHealthEvent(float Percent);
event void FUpdateHealthPointEvent(float Healthpoint);
event void FUpdateScoreEvent();


class UHudWidget: UUserWidget
{
    private int VScore = 0;
    private UProgressBar Health;
    private UTextBlock HealthCount;
    private UTextBlock Score;

    UFUNCTION()
    void RegisterComponents(UProgressBar Health, UTextBlock Score, UTextBlock HealthCount)
    {
        this.Health = Health;
        this.Score = Score;
        this.HealthCount = HealthCount;
        this.Health.SetPercent(1.f);
    }

    UFUNCTION()
    void UpdateHealth(float Percent)
    {
        this.Health.SetPercent(Percent);
    }

    UFUNCTION()
    void UpdateHealthPoint(float HealthPoint)
   {
       float HealthNum = HealthPoint;
       this.HealthCount.Text = FText::FromString("Health: " + HealthNum); 
   }

    UFUNCTION()
    void UpdateScore()
    {
        VScore += 100;
        this.Score.Text = FText::FromString("Score: " + VScore);
    }
};

class UGameOverWidget: UUserWidget
{
    private UButton Restart;
    private UButton Quit;
    APlayerController Player;


    UFUNCTION()
    void RegisterComponents(UButton Restart, UButton Quit)
    {
        this.Restart = Restart;
        this.Quit = Quit;

        Restart.OnClicked.AddUFunction(this, n"RestartExec");
        Quit.OnClicked.AddUFunction(this, n"QuitExec");
    }

    UFUNCTION(NotBlueprintCallable)
    void RestartExec()
    {
        Log("Restared main level");
        Gameplay::OpenLevel(n"Main");
    }

    UFUNCTION(NotBlueprintCallable)
    void QuitExec()
    {
        System::QuitGame(Player, EQuitPreference::Quit, false);
    }
};

class SpaceGameMode: AGameModeBase
{

    UPROPERTY()
    TSubclassOf<UHudWidget> Hud;
    UPROPERTY()
    TSubclassOf<UGameOverWidget> GameoverCls;

    UHudWidget HudWidget;
    UGameOverWidget GameOverWidget;

    FUpdateHealthEvent HealthEvent;
    FUpdateScoreEvent ScoreEvent;
    FUpdateHealthPointEvent HealthPointEvent;
    APlayerController Player;

    UPROPERTY(BlueprintReadWrite)
    float ScorePerEnemy = 100.f;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Player = Gameplay::GetPlayerController(0);
        HudWidget = Cast<UHudWidget>(WidgetBlueprint::CreateWidget(Hud, Player));
        HudWidget.AddToViewport();
        Widget::SetInputMode_GameOnly(Player);
        HealthEvent.AddUFunction(HudWidget, n"UpdateHealth");
        HealthPointEvent.AddUFunction(HudWidget, n"UpdateHealthPoint");
        ScoreEvent.AddUFunction(HudWidget, n"UpdateScore");
    }

    void Gameover()
    {
        GameOverWidget = Cast<UGameOverWidget>(WidgetBlueprint::CreateWidget(GameoverCls, Player));
        GameOverWidget.Player = Player;
        Player.bShowMouseCursor = true;
        Widget::SetInputMode_UIOnlyEx(Player, InWidgetToFocus = GameOverWidget);
        GameOverWidget.AddToViewport();
    }

};
