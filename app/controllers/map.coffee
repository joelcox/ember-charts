App.EmberChartsMapController = App.SlideController.extend

  # ---------
  # Data Selection
  # ---------

  availableDataSets: Ember.computed ->
    _.keys @get('rawDataHash')
  .property 'rawDataHash'

  data: Ember.computed ->
    @get('rawDataHash')[@get 'selectedData']
  .property 'selectedData', 'rawDataHash'

  rawDataHash: Ember.computed ->
    map: App.data.map
    empty: App.data.empty
  selectedData: 'map'
