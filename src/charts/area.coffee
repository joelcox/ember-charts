Ember.Charts.AreaComponent = Ember.Charts.LineComponent.extend(
  classNames: ['area-line']

  area: Ember.computed ->
    d3.svg.area()
      .x((d) => @get('xTimeScale') d.group)
      .y0((d) => @get('yScale') @get('yDomain')[0])
      .y1((d) => @get('yScale') d.value)
  .property 'xTimeScale', 'yScale'

  areaAttrs: Ember.computed ->
    area = @get 'area'

    d: (d) -> area d.values
    fill: @get 'getLineColor'
    'fill-opacity': 0.5
  .property('area')

  updateLineData: ->
    # Always remove the previous lines, this allows us to maintain the
    # rendering order of bars behind lines
    @removeAllSeries()

    series = @get 'series'
    g = series.enter().append('g').attr('class', 'series')
    g.append('path').attr('class', 'line')
    g.append('path').attr('class', 'area')

    series.exit()
      .remove()

   updateLineGraphic: ->
      series = @get 'series'
      graphicTop = @get 'graphicTop'
      series.attr('transform', "translate(0, #{graphicTop})")
      series.select('path.line')
        .attr(@get 'lineAttrs')
      series.select('path.area')
        .attr(@get 'areaAttrs')

)

Ember.Handlebars.helper('area-chart', Ember.Charts.AreaComponent)
