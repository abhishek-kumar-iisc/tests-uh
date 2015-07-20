!
!
! Copyright (c) 2011 - 2015
!   University of Houston System and UT-Battelle, LLC.
! 
! All rights reserved.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions
! are met:
! 
! o Redistributions of source code must retain the above copyright notice,
!   this list of conditions and the following disclaimer.
! 
! o Redistributions in binary form must reproduce the above copyright
!   notice, this list of conditions and the following disclaimer in the
!   documentation and/or other materials provided with the distribution.
! 
! o Neither the name of the University of Houston System, UT-Battelle, LLC
!    nor the names of its contributors may be used to
!   endorse or promote products derived from this software without specific
!   prior written permission.
! 
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
! "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
! LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
! A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
! HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
! TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
! PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
! LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
! NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
! SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
!

program test_shmem_put
  implicit none
  include 'shmem.fh'

  integer, parameter :: N = 7

  integer                 ::  i,j
  integer                 ::  nextpe
  integer                 ::  me, npes
  logical                 ::  success1

  character                :: dest(1)
  integer*8               :: dest_ptr
  pointer                 (dest_ptr, dest)

  character                :: src(N)

  integer                 :: errcode, abort

! Function definitions
  integer                 :: shmem_my_pe, shmem_n_pes  
  
  call shmem_init()
  me   = shmem_my_pe()
  npes = shmem_n_pes()

! Make sure this job is running on at least 2 PEs
  if(npes .gt. 1) then

    success1 = .TRUE. 

    call shpalloc(dest_ptr, N, errcode, abort)

    do i = 1, N, 1
      dest(i) = 'z'
    end do 

    do i = 1, N, 1
      src(i) = CHAR(40 + i) 
    end do 

    nextpe = mod((me + 1), npes)

    call shmem_barrier_all()
    
    call shmem_character_put(dest, src, N, nextpe)

    call shmem_barrier_all()

    if(me .eq. 0) then
      do i = 1, N, 1
        if(dest(i) .ne. CHAR(40 + i)) then
          success1 = .FALSE.
        end if
      end do 

      if(success1 .eqv. .TRUE.) then
        write(*,*) "Test shmem_character_put: Passed" 
      else
        write(*,*) "Test shmem_character_put: Failed"
      end if
    end if 

    call shmem_barrier_all()

    call shpdeallc(dest_ptr, errcode, abort)

  else
    write(*,*) "Number of PEs must be > 1 to test shmem get, test skipped"
  end if

  call shmem_finalize()

end program
