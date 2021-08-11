module MarvelApi
  module V1
    module AllowedParameterValues
      THUMBNAIL_SIZES = {
        small: 'portrait_small',
        medium: 'portrait_xlarge',
        large: 'portrait_uncanny',
        original: 'detail'
      }.freeze

      SORT_PARAMETER = {
        foc_date: 'focDate',
        on_sale_date: 'onsaleDate',
        title: 'title',
        issue_number: 'issueNumber',
        modified: 'modified',
      }.freeze

      SORT_DIRECTION = {
        asc: '',
        desc: '-'
      }.freeze

      FORMAT_TYPE = {
        comic: 'comic',
        collection: 'collection',
        any: ''
      }.freeze
    end
  end
end