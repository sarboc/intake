import React from 'react'
import PropTypes from 'prop-types'
import EditRelationshipForm from 'common/relationship/EditRelationshipForm'
import {ModalComponent} from 'react-wood-duck'
import SavingButton from 'common/SavingButton'

const renderBody = (editFormRelationship, errors, onChange, person, relationship) => (
  <EditRelationshipForm
    editFormRelationship={editFormRelationship}
    errors={errors}
    onChange={onChange}
    person={person}
    relationship={relationship}
  />
)

const renderFooter = (closeModal, isFormChanged, isSaving, onSave, id) => (
  <div className='row'>
    <div className='col-md-12'>
      <div className='pull-right'>
        {isSaving ? <SavingButton text='Saving'/> :
          <div>
            <button className='btn btn-default' onClick={closeModal}>
              Cancel
            </button>
            <button
              className='btn btn-primary'
              disabled={isFormChanged}
              onClick={() => onSave(id)}
            >
            Save Relationship
            </button>
          </div>
        }
      </div>
    </div>
  </div>
)

const EditRelationshipModal = ({
  closeModal,
  editFormRelationship,
  errors,
  isFormChanged,
  isSaving,
  onChange,
  onSave,
  person,
  relationship,
  show,
}) => (
  <ModalComponent
    closeModal={closeModal}
    showModal={show}
    modalBody={renderBody(editFormRelationship, errors, onChange, person, relationship)}
    modalFooter={renderFooter(closeModal, isFormChanged, isSaving, onSave, editFormRelationship.id)}
    modalSize='large'
    modalTitle='Edit Relationship Type'
  />
)

const personPropType = PropTypes.shape({
  age: PropTypes.string,
  dateOfBirth: PropTypes.string,
  legacy_id: PropTypes.string,
  gender: PropTypes.string,
  name: PropTypes.string,
})
const relationshipPropType = PropTypes.shape({
  absent_parent_code: PropTypes.string,
  age: PropTypes.string,
  dateOfBirth: PropTypes.string,
  legacy_descriptor: PropTypes.object,
  gender: PropTypes.string,
  name: PropTypes.string,
  person_card_exists: PropTypes.bool,
  same_home_code: PropTypes.string,
  secondaryRelationship: PropTypes.string,
  type: PropTypes.string,
  type_code: PropTypes.string,
})

EditRelationshipModal.propTypes = {
  closeModal: PropTypes.func.isRequired,
  editFormRelationship: PropTypes.shape({
    absent_parent_indicator: PropTypes.bool,
    client_id: PropTypes.string,
    end_date: PropTypes.string,
    id: PropTypes.string,
    relationship_type: PropTypes.number,
    relative_id: PropTypes.string,
    same_home_status: PropTypes.string,
    start_date: PropTypes.string,
  }),
  errors: PropTypes.shape({
    started_at: PropTypes.array,
  }),
  isFormChanged: PropTypes.bool,
  isSaving: PropTypes.bool,
  onChange: PropTypes.func,
  onSave: PropTypes.func,
  person: personPropType,
  relationship: relationshipPropType,
  show: PropTypes.bool.isRequired,
}

export default EditRelationshipModal
