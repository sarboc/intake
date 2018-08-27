import relationshipDropdown from 'common/relationship/relationship_dropdown/relationshipDropdown'
import {
  Frodo,
  Gandalf,
  Harmoine,
  GandalfNoDOB,
  HarmoineNoDOB,
  FrodoUnkownGender,
  FrodoUnkownGenderNoDOB,
  HarmoineUnknowGenderNoDOB,
  GandalfUnknowGender,
  genderCodeFF,
  genderCodefF,
  genderCodeFf,
  genderCodefM,
  genderCodeFm,
  genderCodeFM,
  genderCodemF,
  genderCodeMf,
  genderCodeMF,
  genderCodeMm,
  genderCodemM,
  genderCodeMM,
} from './helperMethodsSpec'

describe('RelationshipDropdown', () => {
  describe('#1bothHaveDOBandGender | Younger Male - Older Male', () => {
    const wrapper = relationshipDropdown(
      Frodo,
      Gandalf
    )

    it('should return only | Male - Male', () => {
      expect(wrapper).toContain(genderCodeMM)
      expect(wrapper).not.toContain(genderCodeFM)
    })

    it('should return only | Younger Male - Older Male', () => {
      expect(wrapper).toContain(genderCodemM)
    })
  })

  describe('#2bothHaveDOBandGender | Older Male - Younder Male', () => {
    const wrapper = relationshipDropdown(
      Gandalf,
      Frodo
    )

    it('should return only | Older Male - Younger Male', () => {
      expect(wrapper).toContain(genderCodeMm)
    })
  })

  describe('#3bothHaveDOBandGender | Older Female - Younger Male', () => {
    const wrapper = relationshipDropdown(
      Harmoine,
      Frodo
    )
    it('should return only | Female - Male', () => {
      expect(wrapper).toContain(genderCodeFM)
      expect(wrapper).not.toContain(genderCodeMM)
    })

    it('should return only | Older Female - younger Male', () => {
      expect(wrapper).toContain(genderCodeFm)
    })
  })

  describe('#4.1bothHaveDOBnoPrmaryGender Primary Younger', () => {
    const wrapper = relationshipDropdown(
      FrodoUnkownGender,
      Gandalf
    )

    it('should return mixed younger and Older Male', () => {
      expect(wrapper).toContain(
          genderCodeMM,
          genderCodemM,
          genderCodeFM,
          genderCodefM,
      )
      expect(wrapper).not.toContain(genderCodeMm, genderCodeFm)
    })
  })

  describe('#4.2bothHaveDOBnoPrmaryGender Secondary Younger', () => {
    const wrapper = relationshipDropdown(
      GandalfUnknowGender,
      Frodo
    )

    it('should return mixed younger and Older Male', () => {
      expect(wrapper).toContain(
          genderCodeMM,
          genderCodeMm,
          genderCodeFM,
          genderCodeFm,
      )
      expect(wrapper).not.toContain(genderCodemM, genderCodefM)
    })
  })

  describe('#5bothHaveDOBnoSecndryGender Secondary Gender Unknow', () => {
    const wrapper = relationshipDropdown(
      Gandalf,
      FrodoUnkownGender
    )

    it('should return mixed older and Younger Male', () => {
      expect(wrapper).toContain(
          genderCodeMm,
          genderCodeMf,
          genderCodeMF,
          genderCodeMM,
      )
      expect(wrapper).not.toContain(genderCodemM, genderCodefM)
    })
  })

  describe('#6bothHaveDOBnoGender Both Gender Unknown', () => {
    const wrapper = relationshipDropdown(
      GandalfUnknowGender,
      FrodoUnkownGender
    )

    it('should return mixed older and Younger Male', () => {
      expect(wrapper).toContain(
          genderCodeMm,
          genderCodeMf,
          genderCodeMF,
          genderCodeMM,
          genderCodeFm,
          genderCodeFf,
          genderCodeFF,
      )
      expect(wrapper).not.toContain(genderCodemM, genderCodefM)
    })
  })

  describe('#7NotbothHaveDOB && bothHaveKnownGender Both Known Gender UnKnown DOB', () => {
    const wrapper = relationshipDropdown(
      Frodo,
      GandalfNoDOB
    )

    it('should return only Older or Younger Male gender', () => {
      expect(wrapper).toContain(genderCodeMM, genderCodemM, genderCodeMm)
      expect(wrapper).not.toContain(genderCodeFM, genderCodemF, genderCodeFm)
    })
  })

  describe('#8NotbothHaveDOB && bothHaveKnownGender - Female Known Gender UnKnown DOB', () => {
    const wrapper = relationshipDropdown(
      HarmoineNoDOB,
      Frodo
    )

    it('should return only Older or Younger Female gender', () => {
      expect(wrapper).toContain(genderCodeFM, genderCodeFm, genderCodefM)
      expect(wrapper).not.toContain(genderCodeMM, genderCodemM, genderCodeMm)
    })
  })

  describe('#9.1noDOBnoGender Both DOB & Gender Unknown', () => {
    const wrapper = relationshipDropdown(
      FrodoUnkownGenderNoDOB,
      HarmoineUnknowGenderNoDOB
    )

    it('should return mixed list', () => {
      expect(wrapper).toContain(
          genderCodeMF,
          genderCodemF,
          genderCodeFF,
          genderCodefF,
          genderCodeFM,
          genderCodeFm,
          genderCodeFf,
      )
    })
  })

  describe('#9.2noDOBnoGender Primary DOB & Gender Unknown', () => {
    const wrapper = relationshipDropdown(
      FrodoUnkownGenderNoDOB,
      GandalfNoDOB
    )

    it('should return mixed list', () => {
      expect(wrapper).toContain(
          genderCodeMM,
          genderCodemM,
          genderCodeFM,
          genderCodefM,
          genderCodeFm,
      )
    })
  })

  describe('#9.3noDOBnoGender Secondary DOB & Gender Unknown', () => {
    const wrapper = relationshipDropdown(
      GandalfNoDOB,
      FrodoUnkownGenderNoDOB
    )

    it('should return mixed list', () => {
      expect(wrapper).toContain(
          genderCodeMF,
          genderCodemM,
          genderCodeMf,
          genderCodeMm,
          genderCodemF,
      )
    })
  })
})
