<template>
  <!-- TODO: connect with firebase -->
  <div class="tw-hero tw-min-h-screen lg:tw-bg-base-200">
    <div
      class="tw-card tw-flex-shrink-0 sm:tw-max-w-xl tw-max-w-sm lg:tw-shadow-2xl tw-bg-base-100"
      style="width: 1500px"
    >
      <div class="tw-card-body">
        <div class="text-center">
          <v-img
            :width="100"
            aspect-ratio="1/1"
            src="/images/logo.png"
            class="mx-auto"
          ></v-img>
          <p class="tw-mb-5">
            ระบบจัดการแชตลูกค้า<br />สำหรับร้านค้าใน Social Media
          </p>
          <h5 class="tw-text-3xl font-weight-bold tw-mb-4">สร้างบัญชี ASAP</h5>
        </div>
        <v-form v-model="isFormValid">
          <div class="form-control tw-mt-2">
            <CommonTextField
              :rules="[required, checkEmail]"
              v-model="userInfo.email"
              id="email"
              name="email"
              type="email"
              label="อีเมล"
            />
          </div>
          <div class="form-control tw-mt-2">
            <CommonTextField
              :rules="[required, passwordLength]"
              v-model="userInfo.password"
              id="password"
              name="password"
              label="รหัสผ่าน"
              @click:append-inner="visible = !visible"
              :append-inner-icon="visible ? 'mdi-eye' : 'mdi-eye-off'"
              :type="visible ? 'text' : 'password'"
              counter
            />
          </div>
          <div class="form-control tw-mt-2">
            <CommonTextField
              :rules="[
                required,
                passwordLength,
                confirmPassword(userInfo.confirmPassword, userInfo.password),
              ]"
              v-model="userInfo.confirmPassword"
              id="confirm-password"
              name="confirm-password"
              label="ยืนยันรหัสผ่าน"
              @click:append-inner="confirmVisible = !confirmVisible"
              :append-inner-icon="confirmVisible ? 'mdi-eye' : 'mdi-eye-off'"
              :type="confirmVisible ? 'text' : 'password'"
            />
          </div>
          <div class="form-control tw-mt-2">
            <v-radio-group
              label="คุณเป็นเจ้าของร้านค้าใช่หรือไม่?"
              inline
              hide-details
              v-model="userInfo.isOwner"
            >
              <v-radio
                label="ใช่"
                :value="true"
                color="primary"
                class="tw-mr-7"
              ></v-radio>
              <v-radio
                label="ไม่ใช่"
                :value="false"
                color="primary"
                @click="resetShopValue"
              ></v-radio>
            </v-radio-group>
            <p
              class="tw-text-xs text-error"
              v-if="userInfo?.isOwner === false"
            >
              ในกรณีที่ท่านไม่ใช่เจ้าของร้านค้า ท่านจะมีสิทธิ์เป็น Agent Lead
              หรือ Agent เท่านั้น
            </p>
          </div>
        </v-form>
        <!-- Biz question -->
        <div v-if="!!userInfo?.isOwner">
          <div class="form-control tw-mb-3">
            <CommonTextField
              :rules="[required]"
              v-model="userInfo.shop!.name"
              id="bizName"
              name="bizName"
              type="text"
              label="ชื่อธุรกิจ"
            />
          </div>
          <div class="form-control tw-mb-3">
            <v-autocomplete
              label="ประเภทธุรกิจ"
              id="bizCategory"
              density="compact"
              variant="outlined"
              color="primary"
              :rules="[required]"
              :items="categories"
              v-model="userInfo.shop!.category"
            ></v-autocomplete>
          </div>
          <div class="form-controls tw-mb-3">
            <CommonTextField
              label="รายละเอียด (ไม่จำเป็น)"
              placeholder="เช่น ร้านขายเสื้อผ้า, ร้านเสริมสวย"
              v-model="userInfo.shop!.detail"
            />
          </div>
          <v-form v-model="isSocialValid">
            <div class="form-control tw-mt-5">
              <p>
                ช่องทาง social media
                <span class="text-error">อย่างน้อย 1 ช่องทาง</span>
              </p>
              <v-checkbox
                v-model="selectedSocial"
                label="Facebook"
                value="facebook"
                color="primary"
                hide-details
              ></v-checkbox>
              <CommonTextField
                v-if="selectedSocial.find((value) => value === 'facebook')"
                :rules="
                  selectedSocial.includes('facebook')
                    ? [required, facebookLink]
                    : []
                "
                v-model="userInfo.shop!.social!.facebook"
                label="Facebook Page Link"
              />
              <v-checkbox
                v-model="selectedSocial"
                label="Instagram"
                value="instagram"
                color="primary"
                hide-details
              ></v-checkbox>
              <CommonTextField
                v-if="selectedSocial.find((value) => value === 'instagram')"
                :rules="
                  selectedSocial.includes('instagram')
                    ? [required, instagramLink]
                    : []
                "
                v-model="userInfo.shop!.social!.instagram"
                label="Instagram Page Link"
              />
              <v-checkbox
                v-model="selectedSocial"
                label="Line"
                value="line"
                color="primary"
                hide-details
              ></v-checkbox>
              <CommonTextField
                v-if="selectedSocial.find((value) => value === 'line')"
                :rules="selectedSocial.includes('line') ? [required] : []"
                v-model="userInfo.shop!.social!.line"
                label="ID Line Official Account"
                data-test="idLine"
              />
            </div>
          </v-form>
        </div>
        <div class="form-control tw-my-2">
          <v-btn
            block
            size="large"
            color="primary"
            rounded="lg"
            class="font-weight-bold"
            :disabled="isButtonDisabled"
            @click="handleRegistration(userInfo)"
          >
            สร้างบัญชีผู้ใช้งาน
          </v-btn>
        </div>
        <p class="text-medium-emphasis">
          มีบัญชีอยู่แล้ว?
          <NuxtLink to="/login">
            <a class="text-primary text-decoration-underline"> เข้าสู่ระบบ</a>
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { businessCategories } from '~/data/businessCategories.data'
import UserSignup from '~/interfaces/signup.interface'

useHead({
  title: 'Welcome to ASAP',
})
const {
  checkEmail,
  required,
  passwordLength,
  confirmPassword,
  facebookLink,
  instagramLink,
} = useFormRules()

const { registerUser } = useFirebaseAuth() // auto-imported

const userInfo = ref<UserSignup>({
  email: '',
  password: '',
  confirmPassword: '',
  isOwner: undefined,
  shop: {
    name: '',
    category: '',
    detail: '',
    social: {
      facebook: '',
      instagram: '',
      line: '',
    },
  },
})

const isFormValid = ref(false)
const isSocialValid = ref(false)
const selectedSocial = ref<string[]>([])

const categories = JSON.parse(JSON.stringify(businessCategories))

const isShopInfoValid = computed(() => {
  const shop = userInfo.value?.shop
  return !!shop?.name && !!shop?.category
})

const isButtonDisabled = computed(() => {
  if (userInfo.value?.isOwner === true) {
    return (
      !isFormValid.value ||
      selectedSocial.value.length === 0 ||
      !isShopInfoValid.value ||
      !isSocialValid.value
    )
  } else if (userInfo.value?.isOwner === false) {
    return !isFormValid.value
  } else {
    return true
  }
})

const visible = ref(false)
const confirmVisible = ref(false)

const resetShopValue = () => {
  userInfo.value.shop = {
    name: '',
    category: '',
    detail: '',
    social: {
      facebook: '',
      instagram: '',
      line: '',
    },
  }
}

const handleRegistration = async (user: UserSignup) => {
  await registerUser(user.email, user.password)
}
</script>
