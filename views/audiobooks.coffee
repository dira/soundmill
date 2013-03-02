$ ->
  initialize = ->
    $('.sc-widget').each (index, el) ->
      widget = SC.Widget(el)
      initializeWidget(widget)


  initializeWidget = (widget) ->
    sound = null
    widget.bind SC.Widget.Events.READY, ->

      widget.getCurrentSound (currentSound) ->
        sound = currentSound
        playStartedAt = null

        widget.bind SC.Widget.Events.PLAY, ->
          widget.getPosition (position) ->
            playStartedAt = position

        widget.bind SC.Widget.Events.PAUSE, ->
          widget.getPosition (playEndedAt) ->
            saveProgress(sound, playStartedAt, playEndedAt)


  saveProgress = (sound, playStartedAt, playEndedAt) ->

    duration = playEndedAt - playStartedAt
    progress = Number((duration / sound.duration).toFixed(6))
    data =
      soundcloud_id: sound.id
      duration: duration
      progress: progress

    $.post '/progress', data

  initialize()
