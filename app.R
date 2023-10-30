library(shiny)
library(shinythemes)
library(rvest)  # For web scraping
library(DT)  # Display tables



# Using scraperapi we can get an api key and use this to scrape a table to place into the app.
url <- "http://api.scraperapi.com?api_key=<YOUR-API-KEY-HERE>&url=https://WEBSITE-URL-WITH-TABLE"
wnl_table <- url %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="ID_OF_TABLE_ELEMENT"]') %>% # you can find the table id by right clicking on the table and going to inspect element.
  html_table()




ui = navbarPage("Session Planner", theme = shinytheme("slate"),
                
                # Makes the text colour white in Table output
                
                tags$head(
                  tags$style(HTML(".white-text { color: white; }")),
                  
                  # This HTML code is for inputting the time so that you don't need to place : every time you enter a time. This will do it for you.
                  # Bottom section is for retracting the exercise menu.
                  
                  tags$script(
                    HTML(
                      '
          $(document).on("shiny:connected", function() {
            // Custom JavaScript validation and formatting for time inputs
            var startTimeInput = $("#start_time_input");
            var endTimeInput = $("#end_time_input");
            
            startTimeInput.on("input", function() {
              validateAndFormatTimeInput($(this));
            });
            
            endTimeInput.on("input", function() {
              validateAndFormatTimeInput($(this));
            });
            
            function validateAndFormatTimeInput(input) {
              var pattern = /^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/;
              var value = input.val().trim();
              var isValid = pattern.test(value);
              
              if (!isValid) {
                // Format the input as HH:MM (e.g., 2000 becomes 20:00)
                value = value.replace(/^(\\d{2})(\\d{2})$/, "$1:$2");
                input.val(value);
              }
              
              input.toggleClass("is-invalid", !isValid);
            }
          });

          // Retract the exercise menu after selection
          $(document).on("change", "#exercise_input", function(){
            $(this).selectize()[0].selectize.close();
          });
          '
                    )
                  )
                ),
                
                # Setup list functions for training exercises.
                
                
                tabPanel("Session", icon = icon("futbol"),
                         fluidRow(
                           column(width = 6,
                                  h2("Training Session"),
                                  dateInput("date_input", "Date", value = Sys.Date(), format = "dd-MM"),
                                  selectizeInput("exercise_input", "Exercise", choices = list(
                                    "Warmup" = c(
                                      "Warmup",
                                      "Reactivation",
                                      "Stretch",
                                      "Bands",
                                      "Cool down"
                                    ),
                                    "Technical" = c(
                                      "Rondos",
                                      "Passing pattern",
                                      "Passing",
                                      "Possession",
                                      "Transitional possession",
                                      "ssg",
                                      "ssg + goals",
                                      "1v1",
                                      "2v1",
                                      "2v2",
                                      "3v2",
                                      "3v3",
                                      "4v3",
                                      "4v4",
                                      "11v11",
                                      "Dribbling exercise",
                                      "Murder ball",
                                      "Finishing"
                                    ),
                                    "Tactical" = c(
                                      "Analysis",
                                      "11v11 + set plays",
                                      "Playing out from the back",
                                      "Playing through the thirds",
                                      "Attacking in the final third",
                                      "Phase of play",
                                      "Defensive shape",
                                      "Five zones",
                                      "Transition to defend",
                                      "Transition to attack"
                                    ),
                                    "Goalkeeping" = c(
                                      "1 v 1",
                                      "Footwork and handling",
                                      "Set shape",
                                      "Through balls",
                                      "Reactions",
                                      "2nd saves",
                                      "Shot stopping (outside the box)",
                                      "Shot stopping (inside the box)",
                                      "Positioning for shots",
                                      "Positioning for crosses",
                                      "Decision making",
                                      "Communication",
                                      "Defending the space",
                                      "Defending the area",
                                      "Defending the goal",
                                      "Unit work", 
                                      "TITLE",
                                      "Review of session",
                                      "Distribution"
                                    ),
                                    "Misc" = c(
                                      "Water break",
                                      "Team meeting",
                                      "Gym",
                                      "Injury Prevention",
                                      "Nutrition",
                                      "Beep test",
                                      "Recovery",
                                      "Attacking unit",
                                      "Defensive unit",
                                      "Everyone",
                                      "Match",
                                      "Media",
                                      "Free time"
                                    ),
                                    "Fun Games" = c(
                                      "Head tennis",
                                      "Footgolf",
                                      "Heading game",
                                      "Handball",
                                      "Keepie uppies",
                                      "Levels",
                                      "First time finishing",
                                      "Penalty shootout",
                                      "Tic-tac-toe",
                                      "Relay race"
                                    )
                                  ), multiple = TRUE, options = list(plugins = list("remove_button"))),
                                  textInput("start_time_input", "Start Time", placeholder = "00:00"),
                                  textInput("end_time_input", "End Time", placeholder = "00:00"),
                                  textInput("notes_input", "Notes (Optional)"),
                                  actionButton("add_exercise_button", "Add Exercise"),
                                  actionButton("clear_button", "Clear"),
                                  
                                  # Player selection UI
                                  selectizeInput(
                                    "players", "Select Players:",
                                    choices = unique(players_data$Name),
                                    multiple = TRUE,
                                    options = list('plugins' = list('remove_button'))
                                  ),
                                  actionButton("reset", "Clear Player Selection")
                           ),
                           column(width = 6,
                                  h4(textOutput("session_info")),
                                  tableOutput("exercise_table"),
                                  
                                  # Display selected players in a table
                                  tableOutput("position_summary")
                           )
                         )
                ),
                
                tabPanel("League Table", icon = icon("table"),
                         
                         DTOutput("league_table"),
                         
                         
                         # Links I find useful.
                         
                         fluidRow(
                           column(width = 6,
                                  h4("Links"),
                                  tags$ul(
                                    tags$li(a("England Football Learning", href = "https://learn.englandfootball.com/")),
                                    tags$li(a("Player Development Project", href = "https://playerdevelopmentproject.com/")),
                                    tags$li(a("The Coaching Manual", href = "https://www.thecoachingmanual.com/")),
                                    tags$li(a("Coaches Voice Academy", href = "https://academy.coachesvoice.com/?rfsn=4778590.f475f5")),
                                    tags$li(a("YouTube", href = "https://www.youtube.com/"))
                                  )
                           ),
                           column(width = 6,
                                  h4("Podcasts"),
                                  tags$ul(
                                    tags$li(a("Tifo Football Podcast", href = "https://open.spotify.com/show/06QIGhqK31Qw1UvfHzRIDA")),
                                    tags$li(a("The Athletic Football Podcast", href = "https://open.spotify.com/show/69AAB4ojTuK7gwy3ZdQdB9")),
                                    tags$li(a("OTB Football", href = "https://open.spotify.com/show/5zbUCka6CpkaHvDq4b64iL")),
                                    tags$li(a("Football Weekly - The Guardian", href = "https://open.spotify.com/show/6w8qWe0kjgHEHSWDSDGoLW")),
                                    tags$li(a("Football Daily - BBC", href = "https://open.spotify.com/show/1zMk6kxTYupkRMey1K2If6"))
                                  )
                           ),
                           column(width = 6,
                                  h4("News"),
                                  tags$ul(
                                    tags$li(a("Sky Sports News", href = "https://www.skysports.com/football")),
                                    tags$li(a("ESPN", href = "https://www.espn.com/soccer/")),
                                    tags$li(a("Premier League", href = "https://www.premierleague.com/")),
                                    tags$li(a("FIFA", href = "https://www.fifa.com/fifaplus/en")),
                                    tags$li(a("GOAL", href = "https://www.goal.com/en"))
                                  )
                           ),
                           
                         )
                ))

server <- function(input, output, session) {
  

  exercises <- reactiveValues(data = NULL)
  
  observeEvent(input$add_exercise_button, {
    exercise <- input$exercise_input
    start_time <- input$start_time_input
    end_time <- input$end_time_input
    notes <- input$notes_input
    
    if (!is.null(exercise) && !is.null(start_time) && !is.null(end_time)) {
      new_row <- data.frame(Exercise = exercise, Start_Time = start_time, End_Time = end_time, Notes = notes)
      if (is.null(exercises$data)) {
        exercises$data <- new_row
      } else {
        exercises$data <- rbind(exercises$data, new_row)
      }
    }
    
    updateSelectizeInput(session, "exercise_input", selected = NULL)
    updateTextInput(session, "start_time_input", value = "")
    updateTextInput(session, "end_time_input", value = "")
    updateTextInput(session, "notes_input", value = "")
  })
  
  output$exercise_table <- renderTable({
    exercises$data
  })
  
  output$session_info <- renderText({
    session_date <- format(input$date_input, "%A %d/%m/%Y")
    paste("Session for", session_date)
  })
  
  # Display selected players
  output$selected_players <- renderPrint({
    if (is.null(input$players)) return(NULL)
    selected_players_data <- players_data[players_data$Name %in% input$players, ]
    selected_players_data
  })
  
  # Calculate and display position summary in the custom order
  output$position_summary <- renderTable({
    if (is.null(input$players)) return(NULL)
    summary_data <- players_data[players_data$Name %in% input$players, ]
    summary_data$Position <- factor(summary_data$Position, levels = position_order)
    summary_data <- summary_data %>% group_by(Position) %>% summarise(Count = n())
    summary_data
  })
  
  output$league_table <- DT::renderDataTable({
    if (is.null(wnl_table))
      return(NULL)
    
    datatable(
      wnl_table[[1]], 
      options = list(
        paging = FALSE, # Disable paging for a smaller table
        searching = FALSE, # Disable searching
        dom = 't' # Display only the table, no other elements
      ),
      class = "white-text" # apply the "white-text" CSS class
    )
  })
  
  # Reset player selection
  observeEvent(input$reset, {
    updateSelectizeInput(session, "players", selected = character(0))
  })
}

shinyApp(ui, server)
