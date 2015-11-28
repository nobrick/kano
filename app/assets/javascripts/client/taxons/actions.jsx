const SELECT_TAXON = 'SELECT_TAXON';
const UNSELECT_TAXON = 'UNSELECT_TAXON';

function selectTaxon(code) {
  return { type: SELECT_TAXON, code }
}

function unselectTaxon(code) {
  return { type: UNSELECT_TAXON, code }
}

module.exports = {
  SELECT_TAXON,
  UNSELECT_TAXON,
  selectTaxon,
  unselectTaxon,
}
