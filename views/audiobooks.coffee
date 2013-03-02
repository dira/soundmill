$ ->
  initialize = ->
    widgets = {}
    $('.sc-widget').each (index, el) ->
      widgets[$(el).closest('li').data('book_id')] = initializeWidget(el)

    $('.highlight').submit (e) ->
      e.preventDefault()

      el = $(e.currentTarget)
      book_id = el.closest('li').data('book_id')
      widget = widgets[book_id]
      comment_field = el.find('[name=comment]')

      widget.getCurrentSound (currentSound) ->
        widget.getPosition (position) ->
          data =
            book_id: book_id
            comment: comment_field.val()
            position: Number((position / currentSound.duration).toFixed(6))

          $.post '/highlight', data, (->
            comment_field.val('')
          )


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
    widget


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
