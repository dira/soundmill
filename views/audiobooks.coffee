class Widget
  constructor: (widget, options) ->
    @widget = widget
    @sound = null
    @position = options.position
    @book_id = options.book_id
    @ping_identifier = options.ping_identifier
    @playStartedAt = @position

    @widget.bind SC.Widget.Events.READY, @ready

  ready: =>
    @widget.getCurrentSound @soundReady


  soundReady: (sound) =>
    @sound = sound
    if @position > 0
      @seekPosition()
    else
      @addListeners()


  seekPosition: ->
    # HACK! because seekTo does not work if the sound isn't loaded
    # Thanks to OS users http://bit.ly/14evj9y
    relativePosition = @position / @sound.duration

    @widget.bind SC.Widget.Events.LOAD_PROGRESS, (e) =>
      if e.loadedProgress && e.loadedProgress > relativePosition
        @widget.unbind(SC.Widget.Events.LOAD_PROGRESS)
        @widget.seekTo(@position)
        @widget.pause()
        window.setTimeout @seekDone, 0

    @widget.setVolume(0)
    @widget.play()


  seekDone: =>
    # extra hack, thanks Melissa for the idea!
    @widget.play()
    @widget.pause()

    @widget.setVolume(100)
    @addListeners()


  addListeners: =>
    @widget.bind SC.Widget.Events.PLAY, =>
      @widget.getPosition (position) =>
        @playStartedAt = position

    @widget.bind SC.Widget.Events.PAUSE, =>
      @widget.getPosition (playEndedAt) =>
        # @saveProgress(@playStartedAt, playEndedAt)
        @saveProgress(0, playEndedAt)

  saveProgress: (playStartedAt, playEndedAt) ->
    duration = playEndedAt - playStartedAt
    progress = Number((duration / @sound.duration).toFixed(6))
    data =
      soundcloud_id: @sound.id
      position: playEndedAt
      duration: Math.round(duration/1000)
      progress: progress
      ping_identifier: @ping_identifier

    console.log 'progress', data, @book_id
    $.post '/progress', data


  sendHighlight: (comment, success) ->
    @widget.getPosition (position) =>
      data =
        book_id: @book_id
        comment: comment
        position: Number((position / @sound.duration).toFixed(6))

      console.log 'highlight', data, @book_id
      $.post '/highlight', data, success


  playHighlight: (position, word_count) ->
    start = position * @sound.duration - (word_count * 60/150) * 1000
    @widget.seekTo(start)
    @widget.play()

$ ->
  initialize = ->
    widgets = {}
    window.widgets = widgets
    $('.sc-widget').each (index, el) ->
      book_id = $(el).closest('li').data('book_id')
      position = Number($(el).data('position'))
      widgets[book_id] = new Widget SC.Widget(el),
        book_id: book_id
        position: position
        ping_identifier: $('#books').data('ping_identifier')

    $('.highlight').submit (e) ->
      e.preventDefault()

      el = $(e.currentTarget)
      book_id = el.closest('li').data('book_id')
      comment_field = el.find('[name=comment]')

      widgets[book_id].sendHighlight comment_field.val(), ->
        comment_field.val('')

    $('.highlights li').click (e) ->
      e.preventDefault()

      el = $(e.currentTarget)
      book_id = el.parent().closest('li').data('book_id')
      widgets[book_id].playHighlight(el.data('position'), el.data('nr_words'))


  initialize()
