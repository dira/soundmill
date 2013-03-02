$ ->
  initialize = ->
    $('.sc-widget').each (index, el) ->
      initializeWidget(el)


  initializeWidget = (el) ->
    widget = SC.Widget(el)
    sound = null
    position = Number($(el).data('position'))
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
      position: playEndedAt
      duration: Math.round(duration/1000)
      progress: progress

    $.post '/progress', data

  initialize()
